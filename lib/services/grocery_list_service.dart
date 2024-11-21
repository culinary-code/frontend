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
      final response =
          await ApiClient().authorizedGet('api/Grocery/account/grocery-list');

      if (response == null) {
        print('No access token available');
        return null;
      }

      print('Requesting grocery list with access token to $backendUrl/api/Grocery/account/grocery-list');

      if (response.statusCode == 200) {
        print('Successfully fetched grocery list: ${response.body}');
        Map<String, dynamic> responseBody = json.decode(response.body);

        String? groceryId = responseBody['groceryListId'];
        return groceryId;
      } else {
            'Failed to fetch grocery list: ${response.statusCode}, Response: ${response.body}';
        return null;
      }
    } catch (e) {
      print('Error fetching grocery list ID: $e');
      return null;
    }
  }


  Future<void> addItemToGroceryList(
      String groceryListId, ItemQuantity item) async {
    try {
      final response = await ApiClient().authorizedPut(
        'api/Grocery/$groceryListId/add-item',
        {
          //"itemQuantityId": item.itemQuantityId,
          "quantity": item.quantity,
          "ingredient": {
            "ingredientName": item.groceryListItem.ingredientName,
            "measurement": item.groceryListItem.measurement.index,
          },
        },
      );
      if (response.statusCode == 200) {
        print("Item added successfully: ${response.body}");
      } else {
        print("Failed to add item: ${response.statusCode} - ${response.body}");
        print(response);
      }
    } catch (e) {
      print("Error adding item: $e");
    }
  }
}