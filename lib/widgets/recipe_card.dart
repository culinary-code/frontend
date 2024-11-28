import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../screens/detail_screen.dart';

class RecipeCard extends StatelessWidget {
  final String recipeId;
  final String recipeName;
  final double score;
  final bool isFavorited;
  final VoidCallback onFavoriteToggle;
  final String imageUrl;

  const RecipeCard(
      {super.key,
      required this.recipeId,
      required this.recipeName,
      required this.score,
      required this.isFavorited,
      required this.onFavoriteToggle,
      required this.imageUrl});

  Future<bool> _checkImageUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      print('Error checking image URL: $e');
      return false;
    }
  }

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
                      )));
        },
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 130,
              height: 130,
              color: Colors.blueGrey,
              child: FutureBuilder<bool>(
                future: _checkImageUrl(imageUrl),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.data!) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  } else {
                    return Image.network(
                      imageUrl,
                    );
                  }
                },
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
                            fontWeight: FontWeight.bold, fontSize: 20),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          size: 25,
                          color: isFavorited ? Colors.red : Colors.blueGrey),
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
                                      )));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[50]),
                        child: const Text(
                          "Open",
                          style: TextStyle(fontSize: 18),
                        )),
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
                        else if (score <= 4)
                          const Icon(Icons.star, size: 26, color: Colors.amber)
                      ],
                    )
                  ],
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
