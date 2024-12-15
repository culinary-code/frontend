import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/ingredients/measurement_type.dart';
import 'package:frontend/services/grocery_list_service.dart';

class GroceryListProvider with ChangeNotifier {
  final GroceryListService groceryListService = GroceryListService();

  List<Map<String, dynamic>> _ingredientData = [];
  List<Map<String, dynamic>> _data = [];

  // getters
  List<Map<String, dynamic>> get ingredientData => _ingredientData;
  List<Map<String, dynamic>> get data => _data;

  //setters
  set ingredientData(List<Map<String, dynamic>> newIngredientData){
    _ingredientData = newIngredientData;
    notifyListeners();
  }

  set data(List<Map<String, dynamic>> newData){
    _data = newData;
    notifyListeners();
  }

  void addIngredientData(Map<String, dynamic> ingredient) {
    _ingredientData.add(ingredient);
    compileIngredientData();
    notifyListeners();
  }

  Map<String, dynamic> getIngredientData(String ingredientQuantityId) {
    for (var ingredient in _ingredientData) {
      if (ingredient['ingredientQuantityId'] == ingredientQuantityId) {
        return ingredient;
      }
    }
    throw ArgumentError('Ingredient with ID $ingredientQuantityId not found.');
  }

  void compileIngredientData() {
    // Step 1: Group by ingredientName and measurement
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var ingredient in _ingredientData) {
      String key =
          '${ingredient['ingredientName']}_${ingredient['measurement'].index.toString()}'; // Unique key for grouping
      grouped.putIfAbsent(key, () => []).add(ingredient);
    }

    // Step 2: Calculate total quantities and format the output
    List<Map<String, dynamic>> transformed = grouped.entries.map((entry) {
      String key = entry.key;
      List<Map<String, dynamic>> items = entry.value;

      // Split the key back into ingredientName and measurement
      List<String> splitKey = key.split('_');
      String ingredientName = splitKey[0];
      String measurement = splitKey[1];
      MeasurementType measurementType =
          intToMeasurementType(int.parse(measurement));
      num totalQuantity = items.fold(0, (sum, item) => sum + item['quantity']);

      // Sort the details: "Extra" should always be last
      List<Map<String, dynamic>> sortedDetails = items.map((item) {
        return {
          'ingredientQuantityId': item['ingredientQuantityId'],
          'recipeName': item['recipeName'],
          'quantity': item['quantity'],
          'isIngredient': item['isIngredient']
        };
      }).toList()
        ..sort((a, b) {
          if (a['recipeName'] == "Extra" && b['recipeName'] != "Extra") {
            return 1; // "Extra" goes after other items
          } else if (a['recipeName'] != "Extra" && b['recipeName'] == "Extra") {
            return -1; // Other items go before "Extra"
          } else {
            return 0; // Keep the relative order otherwise
          }
        });

      return {
        'ingredientName': ingredientName,
        'measurement': measurementType,
        'totalQuantity': totalQuantity,
        'details': sortedDetails,
      };
    }).toList();

    // Step 3: Sort ingredients alphabetically by ingredientName
    transformed
        .sort((a, b) => a['ingredientName'].compareTo(b['ingredientName']));

    // Output result
    _data = transformed;
    notifyListeners();
  }

  Future<void> getGroceryListFromDatabase(BuildContext context) async {
    var response = await groceryListService.fetchGroceryListByAccountId(context);

    if (response != null) {
      var ingredients = response['ingredients'];
      var items = response['items'];

      List<Map<String, dynamic>> parsedIngredientData =
          ingredients.map<Map<String, dynamic>>((ingredient) {
        var measurement = ingredient['ingredient']['measurement'];

        // Convert measurement integer to MeasurementType enum
        MeasurementType measurementType;
        if (measurement is int) {
          // Map the integer value to the corresponding MeasurementType
          measurementType = intToMeasurementType(measurement);
        } else {
          measurementType = MeasurementType.kilogram;
        }
        return {
          'ingredientQuantityId': ingredient['ingredientQuantityId'],
          'ingredientName': ingredient['ingredient']['ingredientName'],
          'quantity': ingredient['quantity'].toDouble(),
          'measurement': measurementType,
          'recipeName': ingredient['recipeName']?.isEmpty ?? true
              ? "Extra"
              : ingredient['recipeName'],
          'isIngredient': true
        };
      }).toList();

      List<Map<String, dynamic>> parsedDataItems =
          items.map<Map<String, dynamic>>((item) {
        var measurement = item['groceryItem']['measurement'];

        MeasurementType measurementType;
        if (measurement is int) {
          measurementType = intToMeasurementType(measurement);
        } else {
          measurementType = MeasurementType.kilogram;
        }
        return {
          'ingredientQuantityId': item['itemQuantityId'],
          'ingredientName': item['groceryItem']['groceryItemName'],
          'quantity': item['quantity'].toDouble(),
          'measurement': measurementType,
          'recipeName': "Extra",
          'isIngredient': false
        };
      }).toList();

      // combine both lists

      _ingredientData = parsedIngredientData;
      _ingredientData.addAll(parsedDataItems);

      compileIngredientData();

    }
  }
}
