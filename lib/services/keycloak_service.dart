import 'dart:convert';
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

  final String redirectUrl = "com.culinarycode://login-callback";

  Future<bool> login() async {
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
        await storage.write(key: 'access_token', value: result.accessToken);
        await storage.write(key: 'refresh_token', value: result.refreshToken);
        await storage.write(key: 'id_token', value: result.idToken);
        return true;
      }

      return false;
    } catch (e) {
      print("Error: $e");
    }

    return false;
  }

  Future<void> logout() async {
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

    // Clear stored tokens on logout
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }

  Future<String?> getAccessToken() async {
    print("Getting access token");
    final accessToken = await storage.read(key: 'access_token');

    if (accessToken == null) {
      throw FormatException('Access token not found');
    }

    if (_isTokenExpired(accessToken)) {
      return refreshToken(); // returns new access token
    }

    return accessToken;
  }

  Future<String?> refreshToken() async {
    final refreshToken = await storage.read(key: 'refresh_token');
    final idpBaseUrl = await ApiSelectionProvider().keycloakUrl;
    final issuer = "$idpBaseUrl/realms/$realm";

    if (refreshToken == null) {
      throw FormatException('Refresh token not found');
    }

    try {
      final result = await appAuth.token(
        TokenRequest(
          clientId,
          redirectUrl,
          issuer: issuer,
          refreshToken: refreshToken,
        ),
      );

      await storage.write(key: 'access_token', value: result.accessToken);
      await storage.write(key: 'refresh_token', value: result.refreshToken);

      return result.accessToken;
    } catch (e) {
      throw Exception('Failed to refresh token');
    }
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
