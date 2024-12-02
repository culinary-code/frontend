import 'package:flutter/material.dart';
import 'package:frontend/services/favorite_recipes_service.dart';
import 'package:frontend/models/recipes/recipe.dart';

class FavoriteToggleButton extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onFavoriteToggle;

  const FavoriteToggleButton({
    super.key,
    required this.recipe,
    required this.onFavoriteToggle,
  });

  Future<void> _toggleFavorite(Recipe recipe) async {
    final service = FavoriteRecipeService();

    if (!recipe.isFavorited) {
      final success = await service.addFavoriteRecipe(recipe.recipeId);
      if (success) {
        recipe.isFavorited = true;
      } else {
        // Show an error message
      }
    } else {
      recipe.isFavorited = false;
    }
    onFavoriteToggle();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _toggleFavorite(recipe),
      child: Icon(
        recipe.isFavorited ? Icons.favorite : Icons.favorite_border,
        size: 25,
        color: recipe.isFavorited ? Colors.red : Colors.blueGrey,
      ),
    );
  }
}