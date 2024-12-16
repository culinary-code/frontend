import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:frontend/ErrorNotifier.dart';
import 'package:frontend/models/recipes/recipe_filter.dart';
import 'package:frontend/models/recipes/recipe_suggestion.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:provider/provider.dart';

class RecipeService {
  Future<List<Recipe>> getRecipes(BuildContext context) async {
    final String searchQuery = "o";
    final String searchEndpoint = "Recipe/Collection/ByName/$searchQuery";

    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet(context, searchEndpoint);
    if (response == null) return [];

    if (response.statusCode == 404) {
      return [];
    } else if (response.statusCode != 200) {
      Provider.of<ErrorNotifier>(context, listen: false).showError(
          "Er ging iets mis met het ophalen van recepten. Probeer later opnieuw.");
      return [];
    }

    final List<dynamic> dynamicRecipes = json.decode(response.body);

    final List<Recipe> recipes = dynamicRecipes
        .map((dynamic recipe) => Recipe.fromJson(recipe))
        .toList();

    return recipes;
  }

  Future<List<Recipe>> getFilteredRecipes(BuildContext context,
      String recipeName, List<FilterOption> filterOptions) async {
    final String searchEndpoint = "Recipe/Collection/Filtered";

    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedPost(context, searchEndpoint,
        _buildFilterOptionPayload(recipeName, filterOptions));
    if (response == null) return [];

    if (response.statusCode == 404) {
      return [];
    } else if (response.statusCode != 200) {
      Provider.of<ErrorNotifier>(context, listen: false).showError(
          "Er ging iets mis met het ophalen van recepten. Probeer later opnieuw.");
      return [];
    }

    final List<dynamic> dynamicRecipes = json.decode(response.body);

    final List<Recipe> recipes = dynamicRecipes
        .map((dynamic recipe) => Recipe.fromJson(recipe))
        .toList();

    return recipes;
  }

  Future<List<Recipe>> getRecipesByName(
      BuildContext context, String query) async {
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet(
        context, 'Recipe/Collection/ByName/$query');
    if (response == null) return [];

    if (response.statusCode == 404) {
      return [];
    } else if (response.statusCode != 200) {
      Provider.of<ErrorNotifier>(context, listen: false).showError(
          "Er ging iets mis met het ophalen van recepten. Probeer later opnieuw.");
      return [];
    }

    final List<dynamic> dynamicRecipes = json.decode(response.body);

    final List<Recipe> recipes = dynamicRecipes
        .map((dynamic recipe) => Recipe.fromJson(recipe))
        .toList();

    return recipes;
  }

  Future<Recipe?> getRecipeById(BuildContext context, String id) async {
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet(context, 'Recipe/$id');
    if (response == null) return null;

    if (response.statusCode == 404) {
      Provider.of<ErrorNotifier>(context, listen: false)
          .showError("Het recept werd niet gevonden.");
      return null;
    } else if (response.statusCode != 200) {
      Provider.of<ErrorNotifier>(context, listen: false).showError(
          "Er ging iets mis met het ophalen van je recept. Probeer later opnieuw.");
      return null;
    }

    final dynamic recipe = json.decode(response.body);

    return Recipe.fromJson(recipe);
  }

  Future<String?> createRecipe(BuildContext context, String recipename,
      String description, List<FilterOption> filterOptions) async {
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedPost(
        context,
        'Recipe/Create',
        _buildFilterOptionPayload(recipename, filterOptions,
            description: description));
    if (response == null) return null;

    if (response.statusCode == 200) {
      final dynamic recipe = json.decode(response.body);

      return recipe['recipeId'];
    }

    Provider.of<ErrorNotifier>(context, listen: false).showError(
        "Er ging iets mis met het aanmaken van je recept. Probeer later opnieuw.");

    return '';
  }

  Map<String, dynamic> _buildFilterOptionPayload(
      String recipename, List<FilterOption> filterOptions,
      {String description = ""}) {
    List<String> ingredients = [];
    var difficulty = "";
    var cooktime = 0;
    var mealtype = "";

    for (var option in filterOptions) {
      switch (option.type) {
        case FilterType.ingredient:
          ingredients.add(option.value);
        case FilterType.difficulty:
          difficulty = option.value;
        case FilterType.cookTime:
          cooktime = int.parse(option.value);
        case FilterType.mealType:
          mealtype = option.value;
        default:
      }
    }

    return {
      "RecipeName": recipename,
      "Ingredients": ingredients,
      "Difficulty": difficulty,
      "CookTime": cooktime,
      "MealType": mealtype,
      "Description": description,
    };
  }

  Future<List<RecipeSuggestion>> getRecipeSuggestions(BuildContext context,
      String recipename, List<FilterOption> filterOptions) async {
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedPost(
        context,
        'Recipe/GetSuggestions',
        _buildFilterOptionPayload(recipename, filterOptions));
    if (response == null) return [];

    if (response.statusCode != 200) {
      Provider.of<ErrorNotifier>(context, listen: false).showError(
          "Er ging iets mis met het ophalen van recept suggesties. Probeer later opnieuw.");
      return [];
    }

    final List<dynamic> dynamicSuggestions = json.decode(response.body);

    final List<RecipeSuggestion> suggestions = dynamicSuggestions
        .map((dynamic suggestion) => RecipeSuggestion.fromJson(suggestion))
        .toList();

    return suggestions;
  }
}
