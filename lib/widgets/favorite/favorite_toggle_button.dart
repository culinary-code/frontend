import 'package:flutter/material.dart';
import 'package:frontend/services/favorite_recipes_service.dart';
import 'package:frontend/models/recipes/recipe.dart';


class FavoriteToggleButton extends StatefulWidget {
  final Recipe recipe;

  const FavoriteToggleButton({super.key, required this.recipe});

  @override
  State<FavoriteToggleButton> createState() => _FavoriteToggleButtonState();
}

class _FavoriteToggleButtonState extends State<FavoriteToggleButton> {
  Future<void> _toggleFavorite(BuildContext context, Recipe recipe) async {
    final favoriteRecipeService = FavoriteRecipeService();
    final recipe = widget.recipe;

    // Only add to favorites if not already favorited
    if (!recipe.isFavorited) {
      final success = await favoriteRecipeService.addFavoriteRecipe(recipe.recipeId);
      if (success) {
        recipe.isFavorited = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add recipe to favorites'), backgroundColor: Colors.red,),
        );
      }
    } else {
      await favoriteRecipeService.deleteFavoriteRecipe(recipe.recipeId);
      recipe.isFavorited = false;
    }

    // Trigger a rebuild to update the UI
    (context as Element).markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _toggleFavorite(context, widget.recipe),
      child: Icon(
        widget.recipe.isFavorited ? Icons.favorite : Icons.favorite_border,
        size: 25,
        color: widget.recipe.isFavorited ? Colors.red : Colors.blueGrey,
      ),
    );
  }
}