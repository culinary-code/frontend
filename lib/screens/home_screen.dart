import 'package:flutter/material.dart';
import 'package:frontend/models/recipe.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const RecipeOverview(),
      title: 'Culinary Code',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        // Theme of Project
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
  final List<Recipe> _recipes = [
    Recipe(recipeName: "Puree met spinazie", score: 5.0),
    Recipe(recipeName: "Friet met stoofvlees", score: 4.6),
    Recipe(recipeName: "Aardappelgratin met bechamelsaus", score: 4.1),
    Recipe(recipeName: "Garnaalkroketten", score: 0.0, isFavorited: true)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vind jouw recept!")),
      body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What would you like?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const TextField(
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
                  child: ListView.builder(
                itemCount: _recipes.length,
                // TODO: als je echte recepten ophaald limiteren naar bv 4
                itemBuilder: (context, index) {
                  return RecipeCard(
                      recipeName: _recipes[index].recipeName,
                      score: _recipes[index].score,
                      isFavorited: _recipes[index].isFavorited,
                      onFavoriteToggle: () {
                        setState(() {
                          _recipes[index].isFavorited =
                              !_recipes[index].isFavorited;
                        });
                      });
                },
              ))
            ],
          )),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final String recipeName;
  final double score;
  final bool isFavorited;
  final VoidCallback onFavoriteToggle;

  const RecipeCard(
      {super.key,
      required this.recipeName,
      required this.score,
      required this.isFavorited,
      required this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 100,
            height: 100,
            color: Colors.blueGrey,
            child: const Icon(Icons.image, color: Colors.blueGrey),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                child: Row(
                  children: [
                    Text(
                      recipeName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavorited ? Colors.red : Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          //backgroundColor: Colors.blueGrey
                          ),
                      child: const Text("Open")),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Text(score.toStringAsFixed(1)),
                      if (score > 0 && score < 5)
                        const Icon(Icons.star_half, size: 16)
                      else if (score == 0)
                        const Icon(Icons.star_outline, size: 16)
                      else if (score == 5)
                        const Icon(Icons.star, size: 16)
                    ],
                  )
                ],
              )
            ],
          ))
        ],
      ),
    );
  }
}
