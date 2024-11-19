import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/recipes/ingredients/item_quantity.dart';
import 'package:frontend/services/api_client.dart';
import 'package:http/http.dart' as http;

class GroceryListService {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
      (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<String?> getUserIdForGroceryList(String id) async {
    try {
      final response =
          await ApiClient().authorizedGet('api/account/grocery-list');

      if (response == null) {
        print('No access token available');
        return null;
      }

      print(
          'Requesting grocery list with access token to $backendUrl/api/account/grocery-list');

      if (response.statusCode == 200) {
        print('Successfully fetched grocery list: ${response.body}');
        Map<String, dynamic> responseBody = json.decode(response.body);

        String accountId = responseBody['accountId'];
        String groceryId = responseBody['groceryListId'];

        print('Account ID: $accountId');
        return accountId;
        //return response.body;
      } else if (response.statusCode == 401) {
        print('Unauthorized: Invalid access token');
        return null;
      } else if (response.statusCode == 404) {
        print('Grocery list not found: ${response.body}');
        return null;
      } else {
        print(
            'Failed to fetch grocery list: ${response.statusCode}, Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching grocery list ID: $e');
      return id;
    }
  }

  Future<String?> getGroceryListById(String id) async {
    try {
      print(
          'Requesting grocery list with access token to $backendUrl/api/account/grocery-list');

      final response =
          await ApiClient().authorizedGet('api/account/grocery-list');

      if (response.statusCode == 200) {
        print('Successfully fetched grocery list: ${response.body}');
        Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody.containsKey('groceryListId') &&
            responseBody['groceryListId'] != null) {
          final groceryListData = responseBody['groceryListId'];

          if (groceryListData is String) {
            print('GroceryList ID: $groceryListData');
            return groceryListData;
          }

          if (groceryListData is Map<String, dynamic> &&
              groceryListData.containsKey('id')) {
            String groceryListId = groceryListData['id'];
            print('GroceryList ID from object: $groceryListId');
            return groceryListId;
          }
        }

        print('Grocery list is null or improperly formatted.');
        return null;
      } else if (response.statusCode == 401) {
        print('Unauthorized: Invalid access token');
        return null;
      } else if (response.statusCode == 404) {
        print('Grocery list not found: ${response.body}');
        return null;
      } else {
        print(
            'Failed to fetch grocery list: ${response.statusCode}, Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching grocery list ID: $e');
      return null;
    }
  }

  Future<void> addItemToGroceryList(
      String groceryListId, ItemQuantity item) async {
    final Uri url =
        Uri.parse("$backendUrl/api/Grocery/$groceryListId/add-item");
    try {
      final response = await ApiClient().authorizedPut(
        'api/Grocery/$groceryListId/add-item',
        {
          "itemQuantityId": item.itemQuantityId,
          "quantity": item.quantity,
          "ingredient": {
            "ingredientId": item.ingredient.ingredientId,
            "ingredientName": item.ingredient.ingredientName,
            "measurement": item.ingredient.measurement.index,
          },
        },
      );

      print("Request URL: $url");
      print("Request Body: ${jsonEncode({
            "itemQuantityId": item.itemQuantityId,
            "quantity": item.quantity,
            "ingredient": {
              "ingredientId": item.ingredient.ingredientId,
              "ingredientName": item.ingredient.ingredientName,
              "measurement": item.ingredient.measurement.index,
            },
          })}");

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
