import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/screens/create_recipe_screen.dart';
import 'package:frontend/services/favorite_recipes_service.dart';
import 'package:frontend/state/favorite_recipe_provider.dart';
import 'package:frontend/state/recipe_filter_options_provider.dart';
import 'package:frontend/widgets/filter/filter_button.dart';
import 'package:frontend/widgets/filter/filter_option_chip.dart';
import 'package:frontend/widgets/recipe_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vind jouw recept!")),
      body: RecipeOverview(),
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
  late TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final FavoriteRecipeService favoriteRecipeService = FavoriteRecipeService();
  late List<Recipe> favoriteRecipes = [];

  @override
  void initState() {
    super.initState();

    _recipesFuture = Future.value([]);

    // Initialize TextEditingController with the current value of recipenamefilter
    final filterProvider =
        Provider.of<RecipeFilterOptionsProvider>(context, listen: false);
    _searchController = TextEditingController(text: filterProvider.recipeName);

    // Listen to TextEditingController changes and update the provider
    _searchController.addListener(() {
      filterProvider.recipeName = _searchController.text;
    });
    _loadRecipes();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _onFilterChanged();
    });
  }

  void _onFilterChanged() {
    final filterProvider =
        Provider.of<RecipeFilterOptionsProvider>(context, listen: false);
    setState(() {
      filterProvider.onFilterChanged(context);
    });
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final favoriteRecipeProvider = Provider.of<FavoriteRecipeProvider>(context, listen: false);
    await favoriteRecipeProvider.loadFavoriteRecipes(context);

    final filterProvider = Provider.of<RecipeFilterOptionsProvider>(context, listen: false);
    final filteredRecipes = await filterProvider.recipes;

    // Set the filtered recipes after loading favorites
    setState(() {
      _recipesFuture = Future.value(filteredRecipes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(fontSize: 20),
                  controller: _searchController,
                  decoration: const InputDecoration(
                      hintText: 'Zoek',
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      suffixIcon: Icon(Icons.search)),
                  onChanged: (value) =>
                      _onSearchChanged(), // value is linked through the controller inside the init function.
                ),
              ),
              SizedBox(
                width: 16,
              ),
              FilterButton(
                onFilterChanged: (bool value) {
                  if (value) {
                    _onFilterChanged();
                  }
                },
              ),
            ],
          ),
          const SizedBox(
            height: 8.0,
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
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints
                                .maxHeight, // Use the constraints here
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                FilterOptionsDisplayWidget(
                                  onDelete: () {
                                    _onFilterChanged();
                                  },
                                ),
                                const SizedBox(height: 8.0),
                                const Center(
                                  child: Text(
                                    'Geen recepten gevonden!',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                const Center(
                                  child: Text(
                                    'Recept met jouw zoekterm aanmaken?',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    String query = _searchController.text;
                                    // Navigate to the CreateRecipeScreen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CreateRecipeScreen(
                                          preloadedRecipeName: query,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Maak een recept aan'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  final recipes = snapshot.data!;
                  return CustomScrollView(
                    slivers: [
                      // Sliver that contains the Wrap (it will scroll with the rest)
                      SliverToBoxAdapter(
                        child: FilterOptionsDisplayWidget(
                          onDelete: () {
                            _onFilterChanged();
                          },
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                            height:
                                8.0), // Space between the Wrap and the ListView
                      ),
                      // Sliver that contains the ListView
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == recipes.length) {
                              return Column(
                                children: [
                                  const Center(
                                    child: Text(
                                      'Recept met jouw zoekterm aanmaken?',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      String query = _searchController.text;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreateRecipeScreen(
                                            preloadedRecipeName: query,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Maak een recept aan'),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            } else {
                              return RecipeCard(
                                recipeId: recipes[index].recipeId,
                                recipeName: recipes[index].recipeName,
                                score: recipes[index].averageRating,
                                recipe: recipes[index],
                                imageUrl: recipes[index].imagePath,
                                recipeAmountOfPeople: 0,
                              );
                            }
                          },
                          childCount: recipes.length + 1, // +1 to add the button below the recipes
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
