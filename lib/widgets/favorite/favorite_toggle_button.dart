import 'package:flutter/material.dart';
import 'package:frontend/services/favorite_recipes_service.dart';
import 'package:frontend/models/recipes/recipe.dart';

class FavoriteToggleButton extends StatelessWidget {
  final Recipe recipe;

  const FavoriteToggleButton({
    super.key,
    required this.recipe,
  });

  Future<void> _toggleFavorite(BuildContext context, Recipe recipe) async {
    final favoriteRecipeService = FavoriteRecipeService();

    // Only add to favorites if not already favorited
    if (!recipe.isFavorited) {
      final success = await favoriteRecipeService.addFavoriteRecipe(recipe.recipeId);
      if (success) {
        recipe.isFavorited = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add recipe to favorites')),
        );
      }
    } else {
      // TODO: Implementatie remove
      recipe.isFavorited = false;
    }

    // Trigger a rebuild to update the UI
    (context as Element).markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _toggleFavorite(context, recipe),
      child: Icon(
        recipe.isFavorited ? Icons.favorite : Icons.favorite_border,
        size: 25,
        color: recipe.isFavorited ? Colors.red : Colors.blueGrey,
      ),
    );
  }
}