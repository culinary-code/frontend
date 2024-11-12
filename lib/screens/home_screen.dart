import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/screens/detail_screen.dart';
import 'package:frontend/services/recipe_service.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const RecipeOverview(),
      title: 'Culinary Code',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RecipeOverview extends StatefulWidget {
  const RecipeOverview({super.key});

  @override
  State<RecipeOverview> createState() => _RecipeOverviewState();
}

class _RecipeOverviewState extends State<RecipeOverview> {
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = RecipeService().getRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vind jouw recept!")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Waar heb je trek in?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const TextField(
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                  hintText: 'Aardappel',
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 16.0,
            ),
            Expanded(
              child: FutureBuilder<List<Recipe>>(
                future: _recipesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No recipes found'));
                  } else {
                    final recipes = snapshot.data!;
                    return ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        return RecipeCard(
                          recipeId: recipes[index].recipeId,
                          recipeName: recipes[index].recipeName,
                          score: recipes[index].score,
                          isFavorited: recipes[index].isFavorited,
                          imageUrl: recipes[index].imagePath,
                          onFavoriteToggle: () {
                            setState(() {
                              recipes[index].isFavorited =
                                  !recipes[index].isFavorited;
                            });
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DetailScreen(recipeId: recipeId,)));
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
                                  builder: (context) => DetailScreen(recipeId: recipeId,)));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[50]),
                        child: const Text(
                          "Open",
                          style: TextStyle(fontSize: 18),
                        )),
                    //geef id recept mee ofzo
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Text(
                          score.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 18),
                        ),
                        if (score > 0 && score < 5)
                          const Icon(Icons.star_half, size: 22)
                        else if (score == 0)
                          const Icon(Icons.star_outline, size: 22)
                        else if (score == 5)
                          const Icon(Icons.star, size: 22)
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
