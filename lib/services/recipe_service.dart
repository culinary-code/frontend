import 'dart:convert';
import 'package:frontend/models/recipes/difficulty.dart';
import 'package:frontend/models/recipes/ingredients/ingredient.dart';
import 'package:frontend/models/recipes/ingredients/ingredient_quantity.dart';
import 'package:frontend/models/recipes/ingredients/measurement_type.dart';
import 'package:frontend/models/recipes/instruction_step.dart';
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
      Uri.parse('$backendUrl/Recipe/Collection/ByName/o'),
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

  Future<Recipe> getRecipeById(String id) async {
    final response = await http.get(
      Uri.parse('$backendUrl/Recipe/$id'),
      headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
    );

    if (response.statusCode != 200) {
      throw FormatException('Failed to load recipe: ${response.body}');
    }

    final dynamic recipe = json.decode(response.body);

    final List<InstructionStep> instructions =
        recipe['instructions'].map<InstructionStep>((dynamic instruction) {
      return InstructionStep(
          instructionStepId: instruction['instructionStepId'],
          instruction: instruction['instruction'],
          stepNumber: instruction['stepNumber']);
    }).toList();

    final List<IngredientQuantity> ingredients = (recipe['ingredients'] as List)
        .map((ingredient) => IngredientQuantity(
              ingredientQuantityId: ingredient['ingredientQuantityId'],
              quantity: ingredient['quantity'],
              ingredient: Ingredient(
                ingredientId: ingredient['ingredient']['ingredientId'],
                ingredientName: ingredient['ingredient']['ingredientName'],
                measurement: intToMeasurementType(
                    ingredient['ingredient']['measurement']),
                ingredientQuantities: [], // Replace with actual data if available
              ),
            ))
        .toList();

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
      instructions: instructions,
      ingredients: ingredients,
    );
  }
}
