import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/accounts/account.dart';
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
      final endpoint = 'api/Account/updateAccount';

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
      final endpoint = 'api/Account/updateFamilySize';

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
}