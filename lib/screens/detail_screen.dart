import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/models/accounts/review.dart';
import 'package:frontend/models/recipes/difficulty.dart';
import 'package:frontend/models/recipes/ingredients/ingredient_quantity.dart';
import 'package:frontend/models/recipes/ingredients/measurement_type.dart';
import 'package:frontend/models/recipes/instruction_step.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/models/recipes/recipe_type.dart';
import 'package:frontend/screens/add_review_screen.dart';
import 'package:frontend/screens/add_to_mealplanner_screen.dart';
import 'package:frontend/services/favorite_recipes_service.dart';
import 'package:frontend/services/recipe_service.dart';
import 'package:frontend/services/review_service.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:frontend/widgets/favorite/favorite_toggle_button.dart';



class DetailScreen extends StatelessWidget {
  final String recipeId;

  const DetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Laten we koken!")),
      body: FutureBuilder<Recipe>(
        future: RecipeService().getRecipeById(recipeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final recipe = snapshot.data;
            return DetailOverview(recipe: recipe!);
          }
        },
      ),
    );
  }
}

class DetailOverview extends StatefulWidget {
  final Recipe recipe;

  const DetailOverview({super.key, required this.recipe});

  @override
  State<DetailOverview> createState() => _DetailOverviewState();
}

// Deze klasse combineert alle individueel aangemaakte klassen.
class _DetailOverviewState extends State<DetailOverview> {
  late Recipe recipe = widget.recipe;
  late final List<IngredientQuantity> _ingredients = recipe.ingredients;
  late final List<InstructionStep> _instructionSteps = recipe.instructions;
  late final int cookingTime = recipe.cookingTime;
  late final RecipeType recipeType = recipe.recipeType;
  late final Difficulty difficulty = recipe.difficulty;
  late bool isFavorited = recipe.isFavorited;
  late var reviews = ReviewService().getReviewsByRecipeId(recipe.recipeId);
  Timer? _debounce;


  final FavoriteRecipeService favoriteRecipeService = FavoriteRecipeService();
  late List<Recipe> favoriteRecipes = [];

  Future<List<Recipe>> getFavoriteRecipes() async {
    favoriteRecipes = await favoriteRecipeService.getFavoriteRecipes();
    return favoriteRecipes;
  }

  @override
  void initState() {
    super.initState();
    searchRecipeInFavorite();
  }

  Future<void> searchRecipeInFavorite() async {
    List<Recipe> recipes = await favoriteRecipeService.getFavoriteRecipes();

    setState(() {
      favoriteRecipes = recipes;
      isFavorited = favoriteRecipes.any((favRecipe) => favRecipe.recipeId == recipe.recipeId);
      recipe.isFavorited = isFavorited;
    });
  }

  void toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecipeHeader(
                recipe: recipe,
                isFavorited: isFavorited,
                onFavoriteToggle: toggleFavorite),
            const SizedBox(height: 16),
            RecipeDetailsGrid(
                cookingTime: cookingTime,
                recipeType: recipeType,
                difficulty: difficulty),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.recipe.description,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 18)),
            ),
            PortionSelector(
              recipeAmountOfPeople: widget.recipe.amountOfPeople,
            ),
            const SizedBox(height: 16.0),
            IngredientsOverview(ingredientList: _ingredients),
            const SizedBox(height: 16.0),
            InstructionsOverview(instructionsSteps: _instructionSteps),
            const SizedBox(height: 16.0),
            Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddToMealplannerScreen(
                                      recipe: recipe,
                                    )));
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(180, 40),
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                      child: const Text('+ Weekoverzicht'),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddReviewScreen(
                                    recipeId: recipe.recipeId))).then((value) {
                          setState(() {
                            _debounce =
                                Timer(const Duration(milliseconds: 500), () {
                              reviews = ReviewService()
                                  .getReviewsByRecipeId(recipe.recipeId);
                              // Update recipe to get the new average rating
                              RecipeService()
                                  .getRecipeById(recipe.recipeId)
                                  .then((value) {
                                setState(() {
                                  recipe = value;
                                });
                              });
                            });
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(180, 40),
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                      child: const Text('Voeg review toe'),
                    ),
                  ]),
            ),
            const SizedBox(height: 16.0),
            ReviewsOverview(
                reviews: reviews,
                averageRating: recipe.averageRating,
                amountOfRatings: recipe.amountOfRatings),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    ));
  }
}

class RecipeHeader extends StatelessWidget {
  final bool isFavorited;
  final VoidCallback onFavoriteToggle;
  final Recipe recipe;

  const RecipeHeader(
      {super.key,
        required this.isFavorited,
        required this.onFavoriteToggle,
        required this.recipe});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(
            recipe.imagePath,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      recipe.recipeName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
              const SizedBox(width: 1),
              FavoriteToggleButton(recipe: recipe)
            ],
          ),
        ],
      ),
    );
  }
}

// Dit is een Grid die enkele kenmerken van het gerecht tonen.
class RecipeDetailsGrid extends StatelessWidget {
  final int cookingTime;
  final RecipeType recipeType;
  final Difficulty difficulty;

  const RecipeDetailsGrid(
      {super.key,
      required this.cookingTime,
      required this.recipeType,
      required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blueGrey[200],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                spreadRadius: 5,
                blurRadius: 8,
                offset: const Offset(0, 5))
          ]),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GridItem(icon: Icons.timer, label: '$cookingTime min'),
            GridItem(
                icon: Icons.dinner_dining,
                label: recipeTypeToStringNl(recipeType)),
            GridItem(
                icon: Icons.thermostat,
                label: difficultyToStringNl(difficulty)),
          ],
        ),
      ),
    );
  }
}

// Dit is een grid Item, zorgt ervoor dat de Receptkenmerken mooi worden afgebeeld
class GridItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const GridItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueGrey[800], size: 30),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

// Hierin maak je een functie waarmee je het aantal porties bepaald.
class PortionSelector extends StatefulWidget {
  final int recipeAmountOfPeople;

  const PortionSelector({super.key, required this.recipeAmountOfPeople});

  @override
  State<PortionSelector> createState() => _PortionSelectorState();
}

class _PortionSelectorState extends State<PortionSelector> {
  late int portions;

  void addPortions() {
    setState(() {
      portions++;
    });
  }

  void removePortions() {
    setState(() {
      if (portions > 1) portions--;
    });
  }

  @override
  void initState() {
    super.initState();
    portions = widget.recipeAmountOfPeople;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_dining,
                    size: 30,
                    color: Colors.blueGrey[800],
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Porties',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800]),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: removePortions,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.blueGrey[200],
                      child: Icon(
                        Icons.remove,
                        color: Colors.blueGrey[800],
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$portions',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: addPortions,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.blueGrey[200],
                      child: Icon(
                        Icons.add,
                        color: Colors.blueGrey[800],
                        size: 18,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

// Je toont hier in een tabel een mooi overzicht van de ingrediënten en hoeveelheden
class IngredientsOverview extends StatelessWidget {
  final List<IngredientQuantity> ingredientList;

  const IngredientsOverview({super.key, required this.ingredientList});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
            border: TableBorder.all(color: Colors.white24),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[200],
                  ),
                  children: const [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Ingrediënt',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Hoeveelheid',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                    ),
                  ]),
              ...ingredientList.map((ingredient) {
                final ingredientName = ingredient.ingredient.ingredientName;
                final quantity =
                    '${ingredient.quantity} ${(ingredient.quantity > 1) ? measurementTypeToStringMultipleNl(ingredient.ingredient.measurement) : measurementTypeToStringNl(ingredient.ingredient.measurement)}';

                return TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              ingredientName,
                              style: const TextStyle(fontSize: 18),
                            ),
                          )),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            quantity,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              })
            ],
          ),
        ));
  }
}

// Hierin zorg je dat de de bereidingswijze stapsgewijs aan de gebruiker getoond worden.
class InstructionsOverview extends StatelessWidget {
  final List<InstructionStep> instructionsSteps;

  const InstructionsOverview({super.key, required this.instructionsSteps});

  @override
  Widget build(BuildContext context) {
    final sortedInstructions = List<InstructionStep>.from(instructionsSteps)
      ..sort((a, b) => a.stepNumber.compareTo(b.stepNumber));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bereidingswijze",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...sortedInstructions.asMap().entries.map((entry) {
            InstructionStep step = entry.value;
            return Text(
              "${step.stepNumber}. ${step.instruction}",
              style: const TextStyle(fontSize: 18),
            );
          }),
        ],
      ),
    );
  }
}

class ReviewsOverview extends StatelessWidget {
  final Future<List<Review>> reviews;
  final double averageRating;
  final int amountOfRatings;

  const ReviewsOverview(
      {super.key,
      required this.reviews,
      required this.averageRating,
      required this.amountOfRatings});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: reviews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final reviews = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Reviews",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 20),
                              ),
                              if (averageRating >= 2 && averageRating < 4)
                                const Icon(Icons.star_half,
                                    size: 35, color: Colors.amber)
                              else if (averageRating < 2)
                                const Icon(Icons.star_outline,
                                    size: 35, color: Colors.amber)
                              else if (averageRating >= 4)
                                const Icon(Icons.star,
                                    size: 35, color: Colors.amber),
                              Text(
                                '($amountOfRatings)',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (reviews!.isEmpty)
                const Text("Er zijn nog geen reviews voor dit recept.")
              else
                SizedBox(
                  // make height change depend on content
                  height: 350, // Adjust the height as needed
                  child: ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.reviewerUsername,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < review.amountOfStars
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 28,
                                  );
                                }),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${review.createdAt.day}-${review.createdAt.month}-${review.createdAt.year}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ExpandableText(
                            review.description,
                            expandText: 'toon meer',
                            collapseText: 'toon minder',
                            maxLines: 2,
                            animation: true,
                            linkColor: Colors.blue,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                ),
            ],
          );
        }
      },
    );
  }
}