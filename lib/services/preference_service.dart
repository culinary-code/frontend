import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/accounts/preferencedto.dart';

import 'api_client.dart';

class PreferenceService {
  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
          (throw Exception('Environment variable BACKEND_BASE_URL not found'));


  Future<List<PreferenceDto>> getStandardPreferences() async {
    try {
      final endpoint = 'api/Preference/getStandardPreference';
      final apiClient = await ApiClient.create();

      final response = await apiClient.authorizedGet(endpoint);

      if (response.statusCode == 200) {
        List<dynamic> preferencesJson = json.decode(response.body);
        print(preferencesJson.map((p) => PreferenceDto.fromJson(p)).toList());
        return preferencesJson.map((p) => PreferenceDto.fromJson(p)).toList();
      } else {
        throw Exception('Error fetching standard preferences: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching standard preferences: $e');
    }
  }
}