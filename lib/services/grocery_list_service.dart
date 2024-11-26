import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/recipes/ingredients/item_quantity.dart';
import 'package:frontend/services/api_client.dart';

class GroceryListService {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
      (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<String?> getGroceryListId() async {
    try {
      final apiClient = await ApiClient.create();
      final response = await apiClient.authorizedGet('api/Grocery/account/grocery-list');

      if (response == null) {
        return null;
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);

        String? groceryId = responseBody['groceryListId'];
        return groceryId;
      } else {
            'Failed to fetch grocery list: ${response.statusCode}, Response: ${response.body}';
        return null;
      }
    } catch (e) {
      return null;
    }
  }


  Future<void> addItemToGroceryList(
      String groceryListId, ItemQuantity item) async {
    try {
      final apiClient = await ApiClient.create();
      final response = await apiClient.authorizedPut(
        'api/Grocery/$groceryListId/add-item',
        {
          "quantity": item.quantity,
          "ingredient": {
            "ingredientName": item.groceryListItem.ingredientName,
            "measurement": item.groceryListItem.measurement.index,
          },
        },
      );
      if (response.statusCode == 200) {
      } else {
        return;
      }
    } catch (e) {
      return;
    }
  }
}