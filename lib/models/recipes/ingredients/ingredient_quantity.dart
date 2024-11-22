import 'package:frontend/models/recipes/ingredients/ingredient.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/screens/grocery_screen.dart';
import 'package:frontend/models/meal_planning/planned_meal.dart';

class IngredientQuantity {
  final String ingredientQuantityId;
  double quantity;
  final Ingredient ingredient;
  Recipe? recipe;
  GroceryList? groceryList;
  PlannedMeal? plannedMeal;

  IngredientQuantity(
      {required this.ingredientQuantityId,
      required this.quantity,
      required this.ingredient,
      this.recipe,
      this.groceryList,
      this.plannedMeal});
}
