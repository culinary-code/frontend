import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KeycloakService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String get idpBaseUrl => dotenv.env['KEYCLOAK_BASE_URL'] ?? 'default_value';
  String get clientId => dotenv.env['KEYCLOAK_CLIENT_ID'] ?? 'default_value';
  String get realm => dotenv.env['KEYCLOAK_REALM'] ?? 'default_value';
  String get backendUrl => dotenv.env['BACKEND_BASE_URL'] ?? 'default_value';

  // Step 2: Create new user in Keycloak
  Future<void> createUser({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse('$backendUrl/KeyCloak/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept' : '*/*'
      },
      body: json.encode({
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password' : password
        ,
      }),
    );

    if (response.statusCode == 201) {
      print('User created successfully');
    } else {
      print('Failed to create user: ${response.body}');
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
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      await storage.write(key: 'access_token', value: responseBody['access_token']);
      await storage.write(key: 'refresh_token', value: responseBody['refresh_token']);
      return true; // Login successful
    } else {
      return false; // Login failed
    }
  }

  Future<void> logout() async {
    // Clear stored tokens on logout
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }
}
