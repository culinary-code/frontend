import 'dart:convert';
import 'dart:math';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/state/api_selection_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();

class KeycloakService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String get clientId =>
      dotenv.env['KEYCLOAK_CLIENT_ID'] ??
      (throw Exception('Environment variable KEYCLOAK_CLIENT_ID not found'));

  String get realm =>
      dotenv.env['KEYCLOAK_REALM'] ??
      (throw Exception('Environment variable KEYCLOAK_REALM not found'));

  bool get developmentMode =>
      dotenv.env['DEVELOPMENT_MODE'] == 'true' ? true : false;

  final String redirectUrl = "com.culinarycode://login-callback";

  Future<bool> loginSecured() async {
    final idpBaseUrl = await ApiSelectionProvider().keycloakUrl;
    final issuer = "$idpBaseUrl/realms/$realm";
    try {
      final AuthorizationTokenResponse? result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          issuer: issuer,
          scopes: ['openid', 'profile', 'email', 'offline_access'],
          promptValues: ['login'],
        ),
      );

      if (result != null) {

        print(result.tokenAdditionalParameters);
        print(result.authorizationAdditionalParameters);

        await storage.write(key: 'access_token', value: result.accessToken);
        await storage.write(key: 'refresh_token', value: result.refreshToken);
        await storage.write(key: 'id_token', value: result.idToken);


        // check account exists in backend on login on /KeyCloak/login
        final apiClient = await ApiClient.create();
        final response = await apiClient.authorizedPost("KeyCloak/login", {});

        if (response.statusCode == 200 || response.statusCode == 201) { // separate out if we want to do a special action on 201
          return true;
        } else {
          await logout();
          return false;
        }
      }

      return false;
    } catch (e) {
      print("Error: $e");
    }

    return false;
  }

  // This method may only ever be used in development mode
  Future<bool> loginDevelopment(String username, String password) async {
    if (!developmentMode) throw Exception('Development mode is disabled');

    final idpBaseUrl = await ApiSelectionProvider().keycloakUrl;
    final response = await http.post(
      Uri.parse('$idpBaseUrl/realms/$realm/protocol/openid-connect/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'password',
        'client_id': clientId,
        'username': username,
        'password': password,
      },
    );
    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      await storage.write(
          key: 'access_token', value: responseBody['access_token']);
      await storage.write(
          key: 'refresh_token', value: responseBody['refresh_token']);
      return true; // Login successful
    } else {
      throw FormatException(responseBody['error_description']); // Login failed
    }
  }

  Future<void> logout() async {
    if (!developmentMode) {
      // End session request
      final idpBaseUrl = await ApiSelectionProvider().keycloakUrl;
      final issuer = "$idpBaseUrl/realms/$realm";

      await appAuth.endSession(
        EndSessionRequest(
          issuer: issuer,
          idTokenHint: await storage.read(key: 'id_token'),
          postLogoutRedirectUrl: redirectUrl,
        ),
      );
    }

    // Clear stored tokens on logout
    await clearTokens();
  }

  Future<void> clearTokens() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }

  // only called when development mode is true
  Future<void> createUserDevelopment({
    required String username,
    required String password,
  }) async {
    final Random random = Random();
    final email = 'user${random.nextInt(1000)}@example.com';

    final apiClient = await ApiClient.create();
    final response = await apiClient.unauthorizedPost(
        'KeyCloak/register',
        {
          'username': username,
          'email': email,
          'password': password,
        });

    if (response.statusCode != 200) {
      throw FormatException('gebruiker aanmaken mislukt: ${response.body}');
    }
  }


  Future<String?> getAccessToken() async {
    final accessToken = await storage.read(key: 'access_token');

    if (accessToken == null) {
      throw FormatException('Access token not found');
    }

    if (_isTokenExpired(accessToken)) {
      return refreshAccessToken(); // returns new access token
    }

    return accessToken;
  }

  Future<String?> refreshAccessToken() async {
    final refreshToken = await storage.read(key: 'refresh_token');
    final idpBaseUrl = await ApiSelectionProvider().keycloakUrl;

    if (refreshToken == null) {
      throw FormatException('Refresh token not found');
    }

    String newRefreshToken;
    String newAccessToken;

    if (!developmentMode) {
      try {
        final issuer = "$idpBaseUrl/realms/$realm";
        final result = await appAuth.token(
          TokenRequest(
            clientId,
            redirectUrl,
            issuer: issuer,
            refreshToken: refreshToken,
          ),
        );

        newRefreshToken = result.refreshToken!;
        newAccessToken = result.accessToken!;
      } catch (e) {
        throw FormatException('Failed to refresh token');
      }
    } else {
      final response = await http.post(
        Uri.parse('$idpBaseUrl/realms/$realm/protocol/openid-connect/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'refresh_token',
          'client_id': clientId,
          'refresh_token': refreshToken,
        },
      );

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        newRefreshToken = responseBody['refresh_token'];
        newAccessToken = responseBody['access_token'];
      } else {
        throw FormatException(responseBody['error_description']);
      }
    }

    await storage.write(key: 'access_token', value: newAccessToken);
    await storage.write(key: 'refresh_token', value: newRefreshToken);

    return newAccessToken;
  }

  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT token');
    }

    final payload = _base64Decode(parts[1]);
    return json.decode(payload);
  }

  String _base64Decode(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    while (output.length % 4 != 0) {
      output += '=';
    }
    return utf8.decode(base64Url.decode(output));
  }

  bool _isTokenExpired(String token) {
    final Map<String, dynamic> decodedToken = _decodeJwt(token);
    final exp = decodedToken['exp'];
    final expirationTime =
        DateTime.fromMillisecondsSinceEpoch(exp * 1000).toUtc();
    return DateTime.now().toUtc().isAfter(expirationTime);
  }
}
