import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/recipes/ingredients/item_quantity.dart';
import 'package:frontend/services/api_client.dart';
import 'package:http/http.dart' as http;

import '../models/recipes/ingredients/ingredient.dart';
import '../models/recipes/ingredients/measurement_type.dart';

class GroceryListService {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
      (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<String?> getGroceryListId() async {
    try {
      print('Janno');
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
        print('groceryId $groceryId' + responseBody['groceryListId']);

        if (groceryId == null) {
          print('groceryListId is null in the response.');
          return null;
        }

        return groceryId;
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

  Future<List<ItemQuantity>> getGroceryItems() async {
    try {
      final groceryListId = await getGroceryListId();
      if (groceryListId == null) {
        throw Exception('No grocery list found');
      }

      final response = await ApiClient().authorizedGet('api/Grocery/account/grocery-list');

      if (response.statusCode != 200) {
        throw FormatException('Failed to load grocery items: ${response.body}');
      }

      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Combine the 'items' and 'ingredients' data from the response
      final List<ItemQuantity> groceryItems = [];

      final items = responseBody['items'] as List<dynamic>;
      final ingredients = responseBody['ingredients'] as List<dynamic>;

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final ingredientData = ingredients.firstWhere(
                (ingredient) => ingredient['ingredientQuantityId'] == item['ingredientQuantityId'],
            orElse: () => {});

        // Only add if a valid ingredient is found for this item
        if (ingredientData.isNotEmpty) {
          final ingredient = Ingredient(
            ingredientId: ingredientData['ingredient']['ingredientId'],
            ingredientName: ingredientData['ingredient']['ingredientName'],
            measurement: intToMeasurementType(ingredientData['ingredient']['measurement']),
            ingredientQuantities: [], // If necessary, populate this too
          );

          groceryItems.add(ItemQuantity(
            itemQuantityId: item['ingredientQuantityId'],
            quantity: item['quantity'].toDouble(),
            ingredient: ingredient,
          ));
        }
      }

      return groceryItems;
    } catch (e) {
      print('Error fetching grocery items: $e');
      return [];
    }
  }

}
