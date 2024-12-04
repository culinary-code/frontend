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

  Future<Map<String, dynamic>?> fetchGroceryListByAccountId() async {
    try {
      final apiClient = await ApiClient.create();
      final response = await apiClient.authorizedGet('api/Grocery/grocery-list');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<bool> addItemToGroceryList(
      ItemQuantity item) async {
    try {
      final apiClient = await ApiClient.create();
      final response = await apiClient.authorizedPut(
        'api/Grocery/grocery-list/add-item',
        {
          "itemQuantityId": item.itemQuantityId,
          "quantity": item.quantity,
          "groceryItem": {
            "groceryItemName": item.groceryListItem.ingredientName,
            "measurement": item.groceryListItem.measurement.index,
          },
          "isIngredient" : item.isIngredient,
        },
      );

      return response.statusCode == 200;

    } catch (e) {
      return false;
    }
  }

  Future<void> deleteItemFromGroceryList(ItemQuantity item) async {
    try {
      final apiClient = await ApiClient.create();
      final response = await apiClient.authorizedDeleteWithBody(
        'api/Grocery/grocery-list/items', {
        "itemQuantityId": item.itemQuantityId,
        "quantity": item.quantity,
        "groceryItem": {
          "groceryItemName": item.groceryListItem.ingredientName,
          "measurement": item.groceryListItem.measurement.index,
        },
        "isIngredient" : item.isIngredient,
      },
      );

      if (response.statusCode != 200) {
        throw Exception('Item could not be deleted');
      }
    } catch (e) {
      throw Exception('An error occurred while deleting the item: $e');
    }
  }
}
