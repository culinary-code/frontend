import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/ErrorNotifier.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:provider/provider.dart';

import 'api_client.dart';

class FavoriteRecipeService {
  Future<List<Recipe>> getFavoriteRecipes(BuildContext context) async {
    final endpoint = 'api/Account/getFavoriteRecipes';
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet(context, endpoint);
    if (response == null) return [];

    if (response.statusCode == 200) {
      final List<dynamic> dynamicRecipes = json.decode(response.body);
      final List<Recipe> favoriteRecipes = dynamicRecipes.map((dynamic recipe) {
        final Recipe mappedRecipe = Recipe.fromJson(recipe);
        mappedRecipe.isFavorited = true;
        return mappedRecipe;
      }).toList();
      return favoriteRecipes;
    } else if (response.statusCode == 404) {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Geen favoriete recepten gevonden.");
      return [];
    } else {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het ophalen van favoriete recepten. Probeer later opnieuw.");
      return [];
    }

  }

  Future<bool> addFavoriteRecipe(BuildContext context, String recipeId) async {
    final endpoint = 'api/Account/addFavoriteRecipe';
    final apiClient = await ApiClient.create();

    final Map<String, dynamic> body = {'recipeId': recipeId};

    final response = await apiClient.authorizedPost(context, endpoint, body);
    if (response == null) return false;

    if (response.statusCode == 400) {
    Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het toevoegen van je favoriete recept. Probeer later opnieuw.");
    }
    return (response.statusCode == 200);
  }

  Future<void> deleteFavoriteRecipe(BuildContext context, String recipeId) async {
    final endpoint = 'api/Account/deleteFavoriteRecipe/$recipeId';
    final apiClient = await ApiClient.create();

    final response = await apiClient.authorizedDelete(context, endpoint);
    if (response == null) return;

    if (response.statusCode != 200) {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het verwijderen van je favoriete recept. Probeer later opnieuw.");
    }
  }
}
