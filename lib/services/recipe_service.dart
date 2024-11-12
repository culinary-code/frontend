import 'dart:convert';
import 'package:frontend/models/recipes/difficulty.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/models/recipes/recipe_type.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecipeService {

  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
          (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<List<Recipe>> getRecipes() async {

    final response = await http.get(
      // TODO: change endpoint once filtering is implemented
      Uri.parse('$backendUrl/Recipe/Collection/ByName/stoof'),
      headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
    );

    if (response.statusCode != 200) {
      throw FormatException('Failed to load recipes: ${response.body}');
    }

    final List<dynamic> dynamicRecipes = json.decode(response.body);

    final List<Recipe> recipes = dynamicRecipes.map((dynamic recipe) {
      return Recipe(
        recipeId: recipe['recipeId'],
        recipeName: recipe['recipeName'],
        recipeType: intToRecipeType(recipe['recipeType']),
        description: recipe['description'],
        cookingTime: recipe['cookingTime'],
        amountOfPeople: recipe['amountOfPeople'],
        difficulty: intToDifficulty(recipe['difficulty']),
        imagePath: recipe['imagePath'],
        createdAt: DateTime.parse(recipe['createdAt']),
        instructions: [],
        reviews: [],
        plannedMeals: [],
        favoriteRecipes: [],
      );
    }).toList();


    return recipes;
  }
}