import '../recipes/ingredients/ingredient_quantity.dart';
import '../recipes/ingredients/measurement_type.dart';

class GroceryListItem {
  final String ingredientName;
  final MeasurementType measurement;
  final List<IngredientQuantity> ingredientQuantities;

  GroceryListItem({
    required this.ingredientName,
    required this.measurement,
    required this.ingredientQuantities,
  });
}