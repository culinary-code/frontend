import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiSelectionProvider with ChangeNotifier {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String backendUrlEnv = dotenv.env['BACKEND_BASE_URL'] ??
      (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  String keycloakUrlEnv = dotenv.env['KEYCLOAK_BASE_URL'] ??
      (throw Exception('Environment variable KEYCLOAK_BASE_URL not found'));

  Future<String> get backendUrl async {
    String? storedUrl = await storage.read(key: 'api');
    return storedUrl ?? backendUrlEnv;
  }

  Future<String> get keycloakUrl async {
    String? storedUrl = await storage.read(key: 'keycloak');
    return storedUrl ?? keycloakUrlEnv;
  }

  Future<void> setSelectedApi(String newApiUrl) async {
    await storage.write(key: 'api', value: newApiUrl);
    notifyListeners();
  }

  Future<void> setSelectedKeycloak(String newKeycloakUrl) async {
    await storage.write(key: 'keycloak', value: newKeycloakUrl);
    notifyListeners();
  }

  Future<bool> isSelectedApiSet() async {
    return await storage.read(key: 'api') != backendUrlEnv;
  }

  Future<void> clearSelectedApi() async {
    await storage.delete(key: 'api');
    notifyListeners();
  }

  Future<void> clearSelectedKeycloak() async {
    await storage.delete(key: 'keycloak');
    notifyListeners();
  }

  Future<bool> hasSelectedApiSet() async {
    String? storedUrl = await storage.read(key: 'api');
    return storedUrl != null;
  }
}
