import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/ErrorNotifier.dart';
import 'package:frontend/models/recipes/ingredients/item_quantity.dart';
import 'package:frontend/services/api_client.dart';
import 'package:provider/provider.dart';

class GroceryListService {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
      (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<String?> getGroceryListId(BuildContext context) async {
    try {
      final apiClient = await ApiClient.create();
      final response = await apiClient.authorizedGet(context, 'api/Grocery/account/grocery-list');
      if (response == null) return null;

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);

        String? groceryId = responseBody['groceryListId'];
        return groceryId;
      } else {
        Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het ophalen van je boodschappenlijst. Probeer later opnieuw.");
        return null;
      }
    } catch (e) {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het ophalen van je boodschappenlijst. Probeer later opnieuw.");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchGroceryListByAccountId(BuildContext context) async {
    try {
      final apiClient = await ApiClient.create();
      final response = await apiClient.authorizedGet(context, 'api/Grocery/grocery-list');
      if (response == null) return null;

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het ophalen van je boodschappenlijst. Probeer later opnieuw.");
      return null;
    }
    Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het ophalen van je boodschappenlijst. Probeer later opnieuw.");
    return null;
  }

  Future<bool> addItemToGroceryList( BuildContext context,
      ItemQuantity item) async {
    try {
      final apiClient = await ApiClient.create();
      final response = await apiClient.authorizedPut(
        context,
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
      if (response == null) return false;

      if (response.statusCode == 400) {
        Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het toevoegen van je boodschap. Probeer later opnieuw.");
      }
      return (response.statusCode == 200);

    } catch (e) {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het toevoegen van je boodschap. Probeer later opnieuw.");
      return false;
    }
  }

  Future<void> deleteItemFromGroceryList(BuildContext context, ItemQuantity item) async {
    try {
      final apiClient = await ApiClient.create();
      final response = await apiClient.authorizedDeleteWithBody(
        context,
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
      if (response == null) return;

      if (response.statusCode != 200) {
        Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het verwijderen van je boodschap. Probeer later opnieuw.");
      }
    } catch (e) {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het verwijderen van je boodschap. Probeer later opnieuw.");
    }
  }
}
