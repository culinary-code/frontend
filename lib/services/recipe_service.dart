import 'dart:convert';
import 'package:frontend/models/recipes/recipe_filter.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/keycloak_service.dart';
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
  Future<List<Recipe>> getRecipes() async {
    final String searchQuery = "o";
    final String searchEndpoint = "Recipe/Collection/ByName/$searchQuery";

    final response = await ApiClient().authorizedGet(searchEndpoint);

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

  Future<List<Recipe>> getFilteredRecipes(String recipename, List<FilterOption> filterOptions) async {
    final String searchEndpoint = "Recipe/Collection/Filtered";

    List<String> ingredients = [];
    var difficulty = "";
    var cooktime = 0;
    var mealtype = "";

    for (var option in filterOptions) {
      switch (option.type){
        case FilterType.ingredient: ingredients.add(option.value);
        case FilterType.difficulty:
          difficulty = option.value;
        case FilterType.cookTime:
          cooktime = int.parse(option.value); //TODO: change this when it is implemented
        case FilterType.mealType:
          mealtype = option.value;
        default:
      }
    }


    final response = await ApiClient().authorizedPost(searchEndpoint,
        {
          "RecipeName" : recipename,
          "Ingredients" : ingredients,
          "Difficulty" : difficulty,
          "CookTime" : cooktime,
          "MealType" : mealtype,
        });

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

  Future<List<Recipe>> getRecipesByName(String query) async {
    final response = await ApiClient().authorizedGet('Recipe/Collection/ByName/$query');

    if (response.statusCode == 404) {
      return [];
    } else if (response.statusCode != 200) {
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
    final response = await ApiClient().authorizedGet('Recipe/$id');

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

  Future<String> createRecipe(String name) async {
    final response = await ApiClient().authorizedPost('Recipe/Create', {
      'Name': name,
    });

    if (response.statusCode == 400) {
      return response.body;
    }

    if (response.statusCode != 200) {
      throw FormatException('Failed to create recipe: ${response.body}');
    }

    if (response.statusCode == 200) {
      final dynamic recipe = json.decode(response.body);

      return recipe['recipeId'];
    }

    return '';
  }
}
