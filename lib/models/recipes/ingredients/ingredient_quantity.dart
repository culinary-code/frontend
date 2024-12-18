import 'package:frontend/models/meal_planning/grocery_list.dart';
import 'package:frontend/models/recipes/ingredients/ingredient.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/models/meal_planning/planned_meal.dart';

class IngredientQuantity {
  final String ingredientQuantityId;
  double quantity;
  final Ingredient ingredient;
  Recipe? recipe;
  GroceryList? groceryList;
  PlannedMealReduced? plannedMeal;

  IngredientQuantity(
      {required this.ingredientQuantityId,
      required this.quantity,
      required this.ingredient,
      this.recipe,
      this.groceryList,
      this.plannedMeal});
}
