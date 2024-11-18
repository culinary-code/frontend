import 'package:frontend/models/recipes/ingredients/ingredient_quantity.dart';
import 'package:frontend/models/recipes/ingredients/item_quantity.dart';

class GroceryList {
  final String groceryListId;
  final List<IngredientQuantity> ingredients;
  final List<ItemQuantity> items;

  GroceryList(
      {
        required this.groceryListId,
        required this.ingredients,
        required this.items
      });
}
