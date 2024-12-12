import 'dart:convert';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/accounts/account.dart';
import 'package:frontend/models/accounts/preferencedto.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/state/api_selection_provider.dart';

class AccountService {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
      (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<Account> fetchUser() async {
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet('api/Account/');

    if (response.statusCode == 200) {
      try {
        var jsonResponse = json.decode(response.body);
        return Account.fromJson(jsonResponse);
      } catch (e) {
        throw FormatException('Error parsing response: $e');
      }
    } else {
      throw Exception('Failed to load user: ${response.body}');
    }
  }

  Future<String> getUserId() async {
    try {
      String? accessToken = await storage.read(key: 'access_token');
      if (accessToken != null) {
        Map<String, dynamic> payload = _decodeJwt(accessToken);
        return payload['sub'];
      } else {
        throw Exception('Access token not found');
      }
    } catch (e) {
      throw Exception('Error loading user ID: $e');
    }
  }

  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
  }

  Future<void> updateUsername(String userId, String newUsername) async {
    try {
      final endpoint = 'api/Account/updateAccount?actionType=updateusername';

      final apiClient = await ApiClient.create();
      final response = await apiClient.authorizedPut(endpoint, {
        'Name': newUsername,
      });

      if (response.statusCode != 200) {
        throw Exception(
            'Error updating username: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating username: $e');
    }
  }

  Future<void> updateFamilySize(String userId, int newFamilySize) async {
    try {
      final endpoint = 'api/Account/updateAccount?actionType=updatefamilysize';

      final apiClient = await ApiClient.create();
      final response = await apiClient.authorizedPut(endpoint, {
        'FamilySize': newFamilySize,
      });

      if (response.statusCode != 200) {
        throw Exception(
            'Error updating familySize: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating familySize: $e');
    }
  }

  Future<List<PreferenceDto>> getPreferencesByUserId(String userId) async {
    final endpoint = 'api/Account/getPreferences';
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet(endpoint);

    if (response.statusCode == 200) {
      List<dynamic> preferencesJson = json.decode(response.body);
      return preferencesJson.map((p) => PreferenceDto.fromJson(p)).toList();
    } else {
      throw Exception('Error fetching preferences');
    }
  }

  Future<void> addPreference(String userId, PreferenceDto preference) async {
    final endpoint = 'api/Account/addPreference';
    final apiClient = await ApiClient.create();

    final response = await apiClient.authorizedPost(endpoint, {
      'PreferenceName': preference.preferenceName,
    });

    if (response.statusCode != 200) {
      throw Exception(
          'Error adding preference: ${response.statusCode}, ${response.body}');
    }
  }

  Future<void> deletePreference(String preferenceId) async {
    try {
      final endpoint = 'api/Account/deletePreference/$preferenceId';
      final apiClient = await ApiClient.create();

      final response = await apiClient.authorizedDelete(endpoint);

      if (response.statusCode != 200) {
        throw Exception(
            'Error deleting preference: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting preference: $e');
    }
  }



  String get clientId =>
      dotenv.env['KEYCLOAK_CLIENT_ID'] ??
          (throw Exception('Environment variable KEYCLOAK_CLIENT_ID not found'));

  String get realm =>
      dotenv.env['KEYCLOAK_REALM'] ??
          (throw Exception('Environment variable KEYCLOAK_REALM not found'));

  final String redirectUrl = "com.culinarycode://login-callback";


  Future<void> deleteAccount() async {
      final endpoint = 'api/Account/deleteAccount';
      final apiClient = await ApiClient.create();

      final response = await apiClient.authorizedDelete(endpoint);

      if (response.statusCode != 200) {
        throw Exception(
            'Error deleting account: ${response.statusCode}, ${response.body}');
      }
  }
}
