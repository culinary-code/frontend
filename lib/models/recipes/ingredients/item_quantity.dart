import 'package:frontend/models/recipes/ingredients/ingredient.dart';

class ItemQuantity {
  final String itemQuantityId;
  double quantity;
  final Ingredient ingredient;

  ItemQuantity(
  {
  required this.itemQuantityId,
  required this.quantity,
  required this.ingredient
  });
}