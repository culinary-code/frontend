import 'package:flutter/material.dart';
import 'package:frontend/state/favorite_recipe_provider.dart';
import 'package:provider/provider.dart';

class FavoriteToggleButton extends StatelessWidget {
  final String recipeId;

  const FavoriteToggleButton({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteRecipeProvider>(
      builder: (context, favoriteRecipeProvider, child) {
        // Get the current favorite status for the recipe
        bool isFavorited = favoriteRecipeProvider.isFavorited(recipeId);

        return GestureDetector(
          onTap: () async {
            await favoriteRecipeProvider.toggleFavorite(recipeId);
          },
          child: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            size: 25,
            color: isFavorited ? Colors.red : Colors.blueGrey,
          ),
        );
      },
    );
  }
}
