import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/services/favorite_recipes_service.dart';
import 'package:frontend/widgets/recipe_card.dart';


class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: const Text("Jouw Favoriete Recepten!", style: TextStyle(fontWeight: FontWeight.bold),),),
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
    _favoriteRecipesFuture = FavoriteRecipeService().getFavoriteRecipes();
    super.initState();
  }

  void _toggleFavorite(Recipe recipe) {
    setState(() {
      recipe.isFavorited = !recipe.isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: FutureBuilder<List<Recipe>>(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 60, color: Colors.red,),
                  SizedBox(height: 20),
                  Text(
                    'Je hebt nog geen favoriete recepten!',
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
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
                  score: recipe.averageRating,
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