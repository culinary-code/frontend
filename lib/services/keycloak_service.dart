import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KeycloakService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String get idpBaseUrl =>
      dotenv.env['KEYCLOAK_BASE_URL'] ??
      (throw Exception('Environment variable KEYCLOAK_BASE_URL not found'));

  String get clientId =>
      dotenv.env['KEYCLOAK_CLIENT_ID'] ??
      (throw Exception('Environment variable KEYCLOAK_CLIENT_ID not found'));

  String get realm =>
      dotenv.env['KEYCLOAK_REALM'] ??
      (throw Exception('Environment variable KEYCLOAK_REALM not found'));

  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
      (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  // Step 2: Create new user in Keycloak
  Future<void> createUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$backendUrl/KeyCloak/register'),
      headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw FormatException('gebruiker aanmaken mislukt: ${response.body}');
    }
  }

  Future<bool> login(String username, String password) async {
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
        'audience': clientId,
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
    // Clear stored tokens on logout
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }

  Future<String?> getAccessToken() async {
    final accessToken = await storage.read(key: 'access_token');

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    if (_isTokenExpired(accessToken)) {
      return refreshToken(); // returns new access token
    }

    return accessToken;
  }

  Future<String?> refreshToken() async {
    final refreshToken = await storage.read(key: 'refresh_token');
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
      await storage.write(key: 'access_token', value: responseBody['access_token']);
      await storage.write(key: 'refresh_token', value: responseBody['refresh_token']);
      return responseBody['access_token'];
    } else {
      throw FormatException(responseBody['error_description']);
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
    final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expirationTime);
  }
}
