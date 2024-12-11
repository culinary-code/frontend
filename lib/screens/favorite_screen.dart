import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/state/favorite_recipe_provider.dart';
import 'package:frontend/widgets/recipe_card.dart';
import 'package:provider/provider.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Jouw Favoriete Recepten!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [SizedBox(height: 16), Expanded(child: FavoriteRecipes())],
      ),
    );
  }
}

class FavoriteRecipes extends StatefulWidget {
  const FavoriteRecipes({super.key});

  @override
  State<FavoriteRecipes> createState() => _FavoriteRecipesState();
}

class _FavoriteRecipesState extends State<FavoriteRecipes> {
  late Future<void> _favoriteRecipesFuture;

  @override
  void initState() {
    super.initState();
    _favoriteRecipesFuture = _loadFavoriteRecipes();
  }

  Future<void> _loadFavoriteRecipes() async {
    await Provider.of<FavoriteRecipeProvider>(context, listen: false)
        .loadFavoriteRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        child: Consumer<FavoriteRecipeProvider>(
            builder: (context, favoriteRecipeProvider, child) {
          List<Recipe> favoriteRecipes = favoriteRecipeProvider.favoriteRecipes;

          if (favoriteRecipes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 60,
                    color: Colors.red,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Je hebt nog geen favoriete recepten!',
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: favoriteRecipes.length,
            itemBuilder: (context, index) {
              final recipe = favoriteRecipes[index];
              return RecipeCard(
                recipeId: recipe.recipeId,
                recipeName: recipe.recipeName,
                score: recipe.averageRating,
                recipe: recipe,
                imageUrl: recipe.imagePath,
                recipeAmountOfPeople: 0,
              );
            },
          );
        }));
  }
}
