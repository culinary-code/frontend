import 'package:frontend/models/recipes/ingredients/ingredient_quantity.dart';
import 'package:frontend/models/recipes/recipe.dart';

class PlannedMealReduced {
  final int amountOfPeople;
  final Recipe recipe;
  final DateTime plannedDay;


  PlannedMealReduced({
    required this.amountOfPeople,
    required this.recipe,
    required this.plannedDay});
}

class PlannedMealFull {
  final int amountOfPeople;
  final Recipe recipe;
  final DateTime plannedDay;
  final List<IngredientQuantity> ingredients;

  PlannedMealFull({
    required this.amountOfPeople,
    required this.recipe,
    required this.plannedDay,
    required this.ingredients
  });

  Map<String, dynamic> toJson() {
    return {
      "amountOfPeople": amountOfPeople,
      "ingredients": ingredients.map((iq) => {
        "ingredientQuantityId": iq.ingredientQuantityId,
        "quantity": iq.quantity,
        "ingredient": {
          "ingredientId": iq.ingredient.ingredientId,
          "name": iq.ingredient.ingredientName,
        },
      }).toList(),
      "recipe": {
        "recipeId" : recipe.recipeId
      },
      "plannedDate": DateTime(plannedDay.year, plannedDay.month, plannedDay.day).toIso8601String(),
    };
  }
}