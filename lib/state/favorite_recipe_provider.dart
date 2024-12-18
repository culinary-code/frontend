import 'package:flutter/cupertino.dart';
import 'package:frontend/services/favorite_recipes_service.dart';
import 'package:frontend/models/recipes/recipe.dart';

class FavoriteRecipeProvider extends ChangeNotifier {
  final FavoriteRecipeService _favoriteRecipeService = FavoriteRecipeService();

  // This list stores the favorite recipes
  List<Recipe> _favoriteRecipes = [];

  // Getter to access favorite recipes list
  List<Recipe> get favoriteRecipes => _favoriteRecipes;

  // Method to check if a recipe is favorited
  bool isFavorited(String recipeId) {
    // Check if the recipeId exists in the _favoriteRecipes list
    return _favoriteRecipes.any((recipe) => recipe.recipeId == recipeId);
  }

  // Fetch favorite recipes from the backend and update the state
  Future<void> loadFavoriteRecipes(BuildContext context) async {
    final List<Recipe> favoriteRecipesList =
        await _favoriteRecipeService.getFavoriteRecipes(context);

    _favoriteRecipes = favoriteRecipesList;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  // Toggle the favorite status for a specific recipe
  Future<void> toggleFavorite(BuildContext context, String recipeId) async {
    bool isCurrentlyFavorited = isFavorited(recipeId);

    if (isCurrentlyFavorited) {
      // If already favorited, remove it
      await _favoriteRecipeService.deleteFavoriteRecipe(context, recipeId);
      _favoriteRecipes.removeWhere((recipe) => recipe.recipeId == recipeId);
    } else {
      // If not favorited, add it
      bool success = await _favoriteRecipeService.addFavoriteRecipe(context, recipeId);
      if (success) {
        await loadFavoriteRecipes(context);
      } else {
        throw Exception('Failed to add favorite');
      }
    }

    // Notify listeners to update the UI
    notifyListeners();
  }
}
