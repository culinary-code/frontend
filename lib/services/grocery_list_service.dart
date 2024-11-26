import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/meal_planning/grocery_list.dart';
import 'package:frontend/models/recipes/ingredients/ingredient_quantity.dart';
import 'package:frontend/models/recipes/ingredients/item_quantity.dart';
import 'package:frontend/services/api_client.dart';

class GroceryListService {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
      (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<String?> getGroceryListId() async {
    try {
      final response =
          await ApiClient().authorizedGet('api/Grocery/account/grocery-list');

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

  Future<GroceryList?> fetchGroceryListById(String groceryListId) async {
    try {
      final response = await ApiClient().authorizedGet('api/Grocery/$groceryListId');

      if (response == null) {
        return null;
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to fetch grocery list by ID: ${response.statusCode}, Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('An error occurred while fetching the grocery list: $e');
      return null;
    }
  }


  Future<void> addItemToGroceryList(
      String groceryListId, ItemQuantity item) async {
    try {
      final response = await ApiClient().authorizedPut(
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

  Future<void> addIngredientToGroceryList(
      String groceryListId, IngredientQuantity item) async {
    try {
      final response = await ApiClient().authorizedPut(
        'api/Grocery/$groceryListId/add-item',
        {
          "quantity": item.quantity,
          "ingredient": {
            "ingredientName": item.ingredient.ingredientName,
            "measurement": item.ingredient.measurement.index,
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