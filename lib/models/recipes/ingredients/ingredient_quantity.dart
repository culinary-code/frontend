import 'package:frontend/models/recipes/ingredients/ingredient.dart';
import 'package:frontend/models/recipes/ingredients/meal_planning/PlannedMeal.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/screens/grocery_screen.dart';

class IngredientQuantity {
  final String ingredientQuantityId;
  final double quantity;
  final Ingredient ingredient;
  final Recipe recipe;
  final GroceryList groceryList;
  final PlannedMeal plannedMeal;

  IngredientQuantity(this.plannedMeal, {
    required this.ingredientQuantityId,
    required this.quantity,
    required this.ingredient,
    required this.recipe,
    required this.groceryList,
  });
}