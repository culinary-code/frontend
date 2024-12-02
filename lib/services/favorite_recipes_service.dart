import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/recipes/recipe.dart';

import 'api_client.dart';

class FavoriteRecipeService {
  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
      (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<List<Recipe>> getDummyFavoriteRecipes() async {
    var dummyRecipes = Recipe.recipeList();
    List<Recipe> favoriteRecipes =
        dummyRecipes.where((recipe) => recipe.isFavorited).toList();
    return favoriteRecipes;
  }

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
