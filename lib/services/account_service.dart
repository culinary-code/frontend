import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/accounts/account.dart';
import 'package:frontend/models/accounts/preference.dart';
import 'package:frontend/models/accounts/preferencedto.dart';
import 'package:frontend/services/api_client.dart';

class AccountService {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
          (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<Account> fetchUser(String accountId) async {
    final response = await ApiClient().authorizedGet('api/Account/$accountId');

    if (response.statusCode == 200) {
      try {
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);
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

      final response = await ApiClient().authorizedPut(endpoint, {
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

      final response = await ApiClient().authorizedPut(endpoint, {
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

  Future<void> updateUserPreferences(String userId, List<PreferenceDto> preferences) async {
    try {
      final endpoint = 'api/Account/updatePreferences';  // Your backend endpoint
      final preferencesJson = preferences.map((pref) => pref.toJson()).toList();

      final response = await ApiClient().authorizedPut(endpoint, {'preferences': preferencesJson});

      if (response.statusCode == 200) {
        print('Preferences updated successfully');
      } else {
        throw Exception('Error updating preferences: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating preferences: $e');
    }
  }










/*Future<void> updatePreferences(String userId, List<Preference> newPreferences) async {
    try {
      final endpoint = 'api/Account/updatePreferences';

      final response = await ApiClient().authorizedPut(endpoint, {
        'Preferences': newPreferences,
      });

      if (response.statusCode != 200) {
        throw Exception('Error updating preferences: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating familySize: $e');
    }
  }

  Future<List<Preference>> getPreferences() async {
    try {
      final endpoint = 'api/Account/getPreferences';
      final response = await ApiClient().authorizedGet(endpoint);

      if (response.statusCode == 200) {
        List<dynamic> preferencesJson = json.decode(response.body);
        return preferencesJson.map((p) => Preference.fromJson(p)).toList();
      } else {
        throw Exception('Error fetching preferences: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching preferences: $e');
    }
  }*/
}