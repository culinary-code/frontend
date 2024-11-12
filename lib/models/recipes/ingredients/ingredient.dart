import 'ingredient_quantity.dart';
import 'measurement_type.dart';

class Ingredient {
  final String ingredientId;
  final String ingredientName;
  final MeasurementType measurement;
  final List<IngredientQuantity> ingredientQuantities;

  Ingredient({
    required this.ingredientId,
    required this.ingredientName,
    required this.measurement,
    required this.ingredientQuantities,
  });
}