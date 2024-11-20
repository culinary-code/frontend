import 'package:flutter/material.dart';

import '../models/recipes/recipe.dart';
import '../services/favorite_recipes_service.dart';
import '../widgets/recipe_card.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: const Text("Jouw Favoriete Recepten!"),),
        body: Column(
          children: [
            SizedBox(height: 16),
            Expanded(child: FavoriteRecipes())
          ],
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
  late Future<List<Recipe>> _favoriteRecipesFuture;

  @override
  void initState() {
    _favoriteRecipesFuture = FavoriteRecipeService().getDummyFovoriteRecipes();
    super.initState();
  }

  void _toggleFavorite(Recipe recipe) {
    setState(() {
      recipe.isFavorited = !recipe.isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Recipe>>(
        future: _favoriteRecipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No favorite recipes found.'),
            );
          } else {
            final favoriteRecipes = snapshot.data!;
            return ListView.builder(
              itemCount: favoriteRecipes.length,
              itemBuilder: (context, index) {
                final recipe = favoriteRecipes[index];
                return RecipeCard(
                  recipeId: recipe.recipeId,
                  recipeName: recipe.recipeName,
                  score: recipe.score,
                  isFavorited: recipe.isFavorited,
                  onFavoriteToggle: () => _toggleFavorite(recipe),
                  imageUrl: recipe.imagePath,
                );
              },
            );
          }
        },
      ),
    );
  }
}