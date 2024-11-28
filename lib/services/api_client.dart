import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/keycloak_service.dart';
import 'package:frontend/state/api_selection_provider.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  String _backendUrl = '';

  ApiClient._create(this._backendUrl);

  static Future<ApiClient> create() async {
    String backendUrl = await ApiSelectionProvider().backendUrl;
    return ApiClient._create(backendUrl);
  }

  Future<http.Response> authorizedGet(String endpoint) async {
    final accesstoken = await KeycloakService().getAccessToken();
    final response = await http.get(
      Uri.parse('$_backendUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authorization': 'Bearer $accesstoken',
      },
    );
    return response;
  }

  Future<http.Response> unauthorizedGet(String endpoint) async {
    final response = await http.get(
      Uri.parse('$_backendUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    );
    return response;
  }

  Future<http.Response> authorizedPost(String endpoint, Map<String, dynamic> body) async {
    final accesstoken = await KeycloakService().getAccessToken();
    final response = await http.post(
      Uri.parse('$_backendUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authorization': 'Bearer $accesstoken',
      },
      body: jsonEncode(body),
    );

    return response;
  }

  Future<http.Response> unauthorizedPost(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$_backendUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
      body: jsonEncode(body),
    );

    return response;
  }

  Future<http.Response> authorizedPut(String endpoint, Map<String, dynamic> body) async {
    final accesstoken = await KeycloakService().getAccessToken();
    final response = await http.put(
      Uri.parse('$_backendUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authorization': 'Bearer $accesstoken',
      },
      body: jsonEncode(body),
    );

    return response;
  }

  Future<http.Response> unauthorizedPut(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$_backendUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
      body: jsonEncode(body),
    );

    return response;
  }

  Future<http.Response> authorizedDelete(String endpoint) async {
    final accesstoken = await KeycloakService().getAccessToken();
    final response = await http.delete(
      Uri.parse('$_backendUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authorization': 'Bearer $accesstoken',
      },
    );

    return response;
  }

  Future<http.Response> unauthorizedDelete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$_backendUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    );

    return response;
  }
}
