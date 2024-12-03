import 'dart:convert';

import 'package:frontend/models/recipes/recipe.dart';

import 'api_client.dart';

class FavoriteRecipeService {
  Future<List<Recipe>> getFavoriteRecipes() async {
    final endpoint = 'api/Account/getFavoriteRecipes';
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet(endpoint);

    if (response.statusCode == 200) {
      final List<dynamic> dynamicRecipes = json.decode(response.body);
      final List<Recipe> favoriteRecipes = dynamicRecipes.map((dynamic recipe) {
        final Recipe mappedRecipe = Recipe.fromJson(recipe);
        mappedRecipe.isFavorited = true;
        return mappedRecipe;
      }).toList();
      return favoriteRecipes;
    } else {
      return [];
    }
  }

  Future<bool> addFavoriteRecipe(String recipeId) async {
    final endpoint = 'api/Account/addFavoriteRecipe';
    final apiClient = await ApiClient.create();

    final Map<String, dynamic> body = {'recipeId': recipeId};

    final response = await apiClient.authorizedPost(endpoint, body);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> deleteFavoriteRecipe(String recipeId) async {
    try {
      final endpoint = 'api/Account/deleteFavoriteRecipe/$recipeId';
      final apiClient = await ApiClient.create();

      final response = await apiClient.authorizedDelete(endpoint);

      if (response.statusCode != 200) {
        throw Exception(
            'Error deleting favorite recipe: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting favorite recipe: $e');
    }
  }
}