import 'package:frontend/models/recipes/ingredients/ingredient.dart';
import 'package:frontend/models/recipes/ingredients/meal_planning/PlannedMeal.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/screens/grocery_screen.dart';

class IngredientQuantity {
  final String ingredientQuantityId;
  final double quantity;
  final Ingredient ingredient;
  Recipe? recipe;
  GroceryList? groceryList;
  PlannedMeal? plannedMeal;

  IngredientQuantity({
    required this.ingredientQuantityId,
    required this.quantity,
    required this.ingredient,
    this.recipe,
    this.groceryList,
    this.plannedMeal
  });
}