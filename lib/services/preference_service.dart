import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/accounts/preferencedto.dart';
import 'package:provider/provider.dart';

import '../ErrorNotifier.dart';
import 'api_client.dart';

class PreferenceService {
  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
      (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<List<PreferenceDto>> getStandardPreferences(BuildContext context) async {
    final endpoint = 'api/Preference/getStandardPreference';
    final apiClient = await ApiClient.create();

    final response = await apiClient.authorizedGet(context, endpoint);
    if (response == null) return [];

    if (response.statusCode == 200) {
      List<dynamic> preferencesJson = json.decode(response.body);
      return preferencesJson.map((p) => PreferenceDto.fromJson(p)).toList();
    } else {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het ophalen van standaard voorkeuren. Probeer later opnieuw.");
      return [];
    }
  }
}
