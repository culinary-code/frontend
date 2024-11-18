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

        // Extract the accountId from the parsed JSON
        String accountId = responseBody['accountId'];

        print('Account ID: $accountId');
        return accountId; // Return the accountId
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

  /*
  Future<String?> getGroceryListId(String id) async {
    try {
      final accessToken = await ApiClient().authorizedGet(id);

      if (accessToken == null) {
        print('No access token available');
        return null;
      }

      final response = await http.get(
        Uri.parse('$backendUrl/account/grocery-list'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('Making request to $backendUrl/account/grocery-list');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('Failed to fetch grocery list ID: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching grocery list ID: $e');
      return null;
    }
  }
*/

  Future<void> addItemToGroceryList(
      String groceryListId, ItemQuantity item) async {
    final Uri url =
        Uri.parse("$backendUrl/api/Grocery/$groceryListId/add-item");
    try {
      final response = await ApiClient().authorizedPost(
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

/* final FlutterSecureStorage storage = FlutterSecureStorage();

  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
          (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  // Fetch Grocery List for a specific account
  Future<GroceryList> fetchGroceryList(String accountId) async {
    final response = await ApiClient().authorizedGet(
        '$backendUrl/api/Grocery/$accountId/grocery-list'
    );

    if (response.statusCode != 200) {
      throw FormatException('Failed to load grocery list: ${response.body}');
    }

    final data = json.decode(response.body);

    // Parse response into GroceryList model
    return GroceryList(
      groceryListId: data['groceryListId'],
      ingredients: (data['ingredients'] as List<dynamic>).map((ingredient) {
        return IngredientQuantity(
          ingredientQuantityId: ingredient['ingredientQuantityId'],
          quantity: ingredient['quantity'],
          ingredient: Ingredient(
            ingredientId: ingredient['ingredient']['ingredientId'],
            ingredientName: ingredient['ingredient']['ingredientName'],
            measurement: ingredient['ingredient']['measurement'],
            ingredientQuantities: ingredient['quantity'],
          ),
        );
      }).toList(),
      items: (data['items'] as List<dynamic>).map((item) {
        return ItemQuantity(
          itemQuantityId: item['itemQuantityId'],
          quantity: item['quantity'],
          ingredient: Ingredient(
            ingredientId: item['ingredient']['ingredientId'],
            ingredientName: item['ingredient']['ingredientName'],
            measurement: item['ingredient']['measurement'],
            ingredientQuantities: item['quantity'],
          ),
        );
      }).toList(),
    );
  }

  Future<void> addItemToGroceryList(String groceryListId, ItemQuantity item) async {
    final response = await ApiClient().authorizedPost(
      'api/Grocery/$groceryListId/add-item', // The endpoint
      {
        "itemQuantityId": item.itemQuantityId,
        "quantity": item.quantity,
        "ingredient": {
          "ingredientId": item.ingredient.ingredientId,
          "ingredientName": item.ingredient.ingredientName,
          "measurement": item.ingredient.measurement,
        },
      }, // The body as a Map<String, dynamic>
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add item: ${response.body}');
    }
  }*/
}
