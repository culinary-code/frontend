import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/accounts/account.dart';
import 'package:http/http.dart' as http;

class AccountService {
  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
          (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<Account> fetchUser(String accountId) async {
    final response = await http.get(
      Uri.parse('$backendUrl/api/Account/$accountId'),
      headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
    );

    if (response.statusCode == 200) {
      try {
        var jsonResponse = json.decode(response.body);
        return Account.fromJson(jsonResponse);
      } catch (e) {
        print('Error parsing response: $e');
        throw FormatException('Error parsing response: $e');
      }
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load user: ${response.body}');
    }
  }

  Future<bool> updateUsername(String accountId, String newUsername) async {
    final url = Uri.parse('$backendUrl/updateAccount/$accountId');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': newUsername,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      return false;
    }
  }
}