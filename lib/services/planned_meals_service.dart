import 'dart:math';
import 'dart:convert';
import 'package:frontend/models/meal_planning/PlannedMeal.dart';
import 'package:frontend/models/recipes/difficulty.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/recipes/recipe_type.dart';
import 'package:frontend/services/api_client.dart';

class PlannedMealsService {
  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
      (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<List<PlannedMealReduced>> getDummyPlannedMeals(
      DateTime dateTime) async {
    var dummyRecipes = Recipe.recipeList();
    List<PlannedMealReduced> plannedMeals = [];
    Random random = Random();

    for (int i = 0; i < 5; i++) {
      // Choose a random recipe from the list
      Recipe randomRecipe = dummyRecipes[random.nextInt(dummyRecipes.length)];

      // Set the planned day based on the starting date and increment by `i` days
      DateTime plannedDay = dateTime.add(Duration(days: i, hours: 3));

      // Create a PlannedMeal with a random amount of people and the selected recipe
      PlannedMealReduced plannedMeal = PlannedMealReduced(
        amountOfPeople: random.nextInt(5) + 1, // Random between 1 and 5
        recipe: randomRecipe,
        plannedDay: plannedDay,
      );

      plannedMeals.add(plannedMeal);
    }

    return plannedMeals;
  }

  Future<String> createRecipe(PlannedMealFull plannedMeal) async {
    final response = await ApiClient().authorizedPost(
        'api/MealPlanner/PlannedMeal/Create', plannedMeal.toJson());

    if (response.statusCode == 400) {
      return response.body;
    }

    if (response.statusCode != 200) {
      throw FormatException('Failed to create recipe: ${response.body}');
    }

    if (response.statusCode == 200) {
      return 'ok';
    }

    return '';
  }

  Future<List<PlannedMealReduced>> getPlannedMealsByDate(
      DateTime dateTime) async {
    final response =
        await ApiClient().authorizedGet('api/MealPlanner/PlannedMeal/$dateTime');

    if (response.statusCode == 404) {
      return [];
    } else if (response.statusCode != 200) {
      throw FormatException('Failed to load plannedMeals: ${response.body}');
    }

    final List<dynamic> dynamicPlannedMeals = json.decode(response.body);

    final List<PlannedMealReduced> plannedMeals =
        dynamicPlannedMeals.map((dynamic plannedMeal) {
      return PlannedMealReduced(
        amountOfPeople: plannedMeal['amountOfPeople'],
        recipe: Recipe(
          recipeId: plannedMeal['recipe']['recipeId'],
          recipeName: plannedMeal['recipe']['recipeName'],
          recipeType: intToRecipeType(plannedMeal['recipe']['recipeType']),
          description: plannedMeal['recipe']['description'],
          cookingTime: plannedMeal['recipe']['cookingTime'],
          amountOfPeople: plannedMeal['recipe']['amountOfPeople'],
          difficulty: intToDifficulty(plannedMeal['recipe']['difficulty']),
          imagePath: plannedMeal['recipe']['imagePath'],
          createdAt: DateTime.parse(plannedMeal['recipe']['createdAt']),
          instructions: [],
          reviews: [],
          plannedMeals: [],
          favoriteRecipes: [],
        ),
        plannedDay: DateTime.parse(plannedMeal['plannedDate']),
      );
    }).toList();

    return plannedMeals;
  }
}
