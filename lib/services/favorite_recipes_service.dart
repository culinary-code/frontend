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
}
