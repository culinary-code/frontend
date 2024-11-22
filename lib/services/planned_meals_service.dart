import 'dart:math';
import 'package:frontend/models/meal_planning/planned_meal.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlannedMealsService {
  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
      (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<List<PlannedMeal>> getDummyPlannedMeals(DateTime dateTime) async {

    var dummyRecipes = Recipe.recipeList();
    List<PlannedMeal> plannedMeals = [];
    Random random = Random();

    for (int i = 0; i < 5; i++) {
      // Choose a random recipe from the list
      Recipe randomRecipe = dummyRecipes[random.nextInt(dummyRecipes.length)];

      // Set the planned day based on the starting date and increment by `i` days
      DateTime plannedDay = dateTime.add(Duration(days: i, hours: 3));

      // Create a PlannedMeal with a random amount of people and the selected recipe
      PlannedMeal plannedMeal = PlannedMeal(
        amountOfPeople: random.nextInt(5) + 1, // Random between 1 and 5
        recipe: randomRecipe,
        plannedDay: plannedDay,
      );

      plannedMeals.add(plannedMeal);
    }

    return plannedMeals;
  }
}
