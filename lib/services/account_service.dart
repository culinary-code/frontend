import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/ErrorNotifier.dart';
import 'package:frontend/models/accounts/account.dart';
import 'package:frontend/models/accounts/preferencedto.dart';
import 'package:frontend/services/api_client.dart';
import 'package:provider/provider.dart';

class AccountService {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
      (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<Account?> fetchUser(BuildContext context) async {
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet(context, 'api/Account/');
    if (response == null) return null;
    if (response.statusCode == 200) {
      try {
        var jsonResponse = json.decode(response.body);
        return Account.fromJson(jsonResponse);
      } catch (e) {
        Provider.of<ErrorNotifier>(context, listen: false).showError("Er is een probleem opgetreden bij het weergeven van je account. Probeer later opnieuw.");
      }
    } else if (response.statusCode == 404) {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Geen account gevonden. Probeer later opnieuw.");
    } else {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het ophalen van je account. Probeer later opnieuw.");
    }
    return null;
  }

  Future<String?> getUserId(BuildContext context) async {
    try {
      String? accessToken = await storage.read(key: 'access_token');
      if (accessToken != null) {
        Map<String, dynamic>? payload = _decodeJwt(context, accessToken);
        if (payload != null) return payload['sub'];
      } else {
        Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het ophalen van je account. Probeer later opnieuw.");
      }
    } catch (e) {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het ophalen van je account. Probeer later opnieuw.");
    }
    return null;
  }

  Map<String, dynamic>? _decodeJwt(BuildContext context, String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het ophalen van je account. Probeer later opnieuw.");
      return null;
    }

    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
  }

  Future<void> updateUsername(BuildContext context, String newUsername) async {
    try {
      final endpoint = 'api/Account/updateAccount?actionType=updateusername';

      final apiClient = await ApiClient.create();
      final response = await apiClient.authorizedPut(context, endpoint, {
        'Name': newUsername,
      });
      if (response == null) return;

      if (response.statusCode != 200) {
        Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het updaten van je gebruikersnaam. Probeer later opnieuw.");

      }
    } catch (e) {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het updaten van je gebruikersnaam. Probeer later opnieuw.");
    }
  }

  Future<void> updateFamilySize(BuildContext context, int newFamilySize) async {
    try {
      final endpoint = 'api/Account/updateAccount?actionType=updatefamilysize';

      final apiClient = await ApiClient.create();
      final response = await apiClient.authorizedPut(context, endpoint, {
        'FamilySize': newFamilySize,
      });
      if (response == null) return;

      if (response.statusCode != 200) {
        Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het updaten van je familie grootte. Probeer later opnieuw.");

      }
    } catch (e) {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het updaten van je familie grootte. Probeer later opnieuw.");
    }
  }

  Future<List<PreferenceDto>> getPreferencesByUserId(BuildContext context) async {
    final endpoint = 'api/Account/getPreferences';
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet(context, endpoint);
    if (response == null) return [];

    if (response.statusCode == 200) {
      List<dynamic> preferencesJson = json.decode(response.body);
      return preferencesJson.map((p) => PreferenceDto.fromJson(p)).toList();
    } else {
      Provider.of<ErrorNotifier>(context, listen: false).showError(
          "Er is iets misgegaan bij het ophalen van uw voorkeuren. Probeer het later opnieuw.");
      return [];
    }
  }

  Future<void> addPreference(BuildContext context, PreferenceDto preference) async {
    final endpoint = 'api/Account/addPreference';
    final apiClient = await ApiClient.create();

    final response = await apiClient.authorizedPost(context, endpoint, {
      'PreferenceName': preference.preferenceName,
    });
    if (response == null) return;

    if (response.statusCode != 200) {
      Provider.of<ErrorNotifier>(context, listen: false).showError(
          "Er is iets misgegaan bij het verwijderen van uw voorkeur. Probeer het later opnieuw.");
    }
  }

  Future<void> deletePreference(BuildContext context, String preferenceId) async {
    try {
      final endpoint = 'api/Account/deletePreference/$preferenceId';
      final apiClient = await ApiClient.create();

      final response = await apiClient.authorizedDelete(context, endpoint);
      if (response == null) return;

      if (response.statusCode != 200) {
        Provider.of<ErrorNotifier>(context, listen: false).showError(
            "Er is iets misgegaan bij het verwijderen van uw voorkeur. Probeer het later opnieuw.");
      }
    } catch (e) {
      Provider.of<ErrorNotifier>(context, listen: false).showError(
          "Er is iets misgegaan bij het verwijderen van uw voorkeur. Probeer het later opnieuw.");
    }
  }

  String get clientId =>
      dotenv.env['KEYCLOAK_CLIENT_ID'] ??
          (throw Exception('Environment variable KEYCLOAK_CLIENT_ID not found'));

  String get realm =>
      dotenv.env['KEYCLOAK_REALM'] ??
          (throw Exception('Environment variable KEYCLOAK_REALM not found'));

  final String redirectUrl = "com.culinarycode://login-callback";


  Future<void> deleteAccount(BuildContext context) async {
      final endpoint = 'api/Account/deleteAccount';
      final apiClient = await ApiClient.create();

      final response = await apiClient.authorizedDelete(context, endpoint);
      if (response == null) return;

      if (response.statusCode != 200) {
        Provider.of<ErrorNotifier>(context, listen: false).showError(
            "Er is iets misgegaan bij het verwijderen van uw account. Probeer het later opnieuw.");
      }
  }

  Future<void> updateChosenGroupId(BuildContext context, String? chosenGroupId) async {
    final endpoint = 'api/Account/setChosenGroup';
    final apiClient = await ApiClient.create();

    final response = await apiClient.authorizedPut(context, endpoint, {
      'ChosenGroupId': chosenGroupId,
    });

    if (response?.statusCode != 200) {
      Provider.of<ErrorNotifier>(context, listen: false).showError(
        "Er is iets mis gegaan met het updaten van uw groep-status. Probeer het later opnieuw."
      );
    }
  }
}
