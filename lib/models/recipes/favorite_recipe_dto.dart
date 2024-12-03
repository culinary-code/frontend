import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/models/recipes/recipe_type.dart';

import 'difficulty.dart';
import 'instruction_step.dart';

class FavoriteRecipeDto {
  final String FavoriteRecipeId;
  final Recipe recipe;

  FavoriteRecipeDto({required this.FavoriteRecipeId, required this.recipe});

  static FavoriteRecipeDto fromJson(Map<String, dynamic> json) {
    return FavoriteRecipeDto(
        FavoriteRecipeId: json['favoriteRecipeId'],
        recipe: Recipe.fromJson(json)
    );
  }
}