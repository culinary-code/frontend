import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/keycloak_service.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String _backendUrl = dotenv.env['BACKEND_BASE_URL'] ??
      (throw Exception('Environment variable BACKEND_BASE_URL not found'));

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

  Future<http.Response> authorizedPost(String endpoint, Map<String, dynamic> body) async {
    final accesstoken = await KeycloakService().getAccessToken();
    final response = await http.post(
      Uri.parse('$_backendUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authorization': 'Bearer $accesstoken',
      },
      body: body,
    );

    return response;
  }
}
