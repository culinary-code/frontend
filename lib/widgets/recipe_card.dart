import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/screens/detail_screen.dart';
import 'package:http/http.dart' as http;

import 'favorite/favorite_toggle_button.dart';

class RecipeCard extends StatelessWidget {
  final String recipeId;
  final String recipeName;
  final double score;
  final Recipe recipe;
  final String imageUrl;

  const RecipeCard({
    super.key,
    required this.recipeId,
    required this.recipeName,
    required this.score,
    required this.recipe,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                recipeId: recipeId,
              ),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 130,
              height: 130,
              color: Colors.blueGrey,
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipeName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      FavoriteToggleButton(
                        recipeId: recipe.recipeId,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                recipeId: recipeId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(),
                        child: const Text(
                          "Open",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Text(
                            score.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 18),
                          ),
                          if (score >= 2 && score < 4)
                            const Icon(Icons.star_half,
                                size: 26, color: Colors.amber)
                          else if (score < 2)
                            const Icon(Icons.star_outline,
                                size: 26, color: Colors.amber)
                          else if (score >= 4)
                              const Icon(Icons.star, size: 26, color: Colors.amber)
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}