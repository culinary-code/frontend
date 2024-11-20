import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/recipes/recipe.dart';

class FavoriteRecipeService {
  String get backendUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
          (throw Exception('Environment variable BACKEND_BASE_URL not found'));

  Future<List<Recipe>> getDummyFavoriteRecipes() async {

    var dummyRecipes = Recipe.recipeList();
    List<Recipe> favoriteRecipes = dummyRecipes.where((recipe) => recipe.isFavorited).toList();
    return favoriteRecipes;
  }
}