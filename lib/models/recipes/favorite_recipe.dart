import 'package:frontend/models/accounts/account.dart';
import 'package:frontend/models/recipes/recipe.dart';

class FavoriteRecipe {
  final String favoriteRecipeId;
  final Recipe recipe;
  final DateTime createdAt;
  final Account account;

  FavoriteRecipe({
    required this.favoriteRecipeId,
    required this.recipe,
    required this.createdAt,
    required this.account,
  });
}