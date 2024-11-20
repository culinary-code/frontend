import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/models/recipes/recipe_filter.dart';
import 'package:frontend/screens/create_recipe_screen.dart';
import 'package:frontend/screens/detail_screen.dart';
import 'package:frontend/state/RecipeFilterOptionsProvider.dart';
import 'package:http/http.dart' as http;
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

  FilterType selectedFilter = FilterType.select;
  String ingredient = '';

  List<FilterOption> filters = [];
  String recipeNameFilter = "";

  @override
  void initState() {
    super.initState();

    // Initialize TextEditingController with the current value of recipenamefilter
    final filterProvider = Provider.of<RecipeFilterOptionsProvider>(context, listen: false);
    _searchController = TextEditingController(text: filterProvider.recipeName);

    // Listen to TextEditingController changes and update the provider
    _searchController.addListener(() {
      filterProvider.recipeName = _searchController.text;
    });

    // filters = filterProvider.filterOptions;
    // recipeNameFilter = filterProvider.recipeName;
    // _recipesFuture = filterProvider.recipes;

    // _onFilterChanged();
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
    final filterProvider = Provider.of<RecipeFilterOptionsProvider>(context, listen: false);
    setState(() {
      filterProvider.onFilterChanged();
    });
  }

  void _showFilterPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return FilterPopup(
            initialFilter: FilterType.select,
            initialIngredient: '',
            onFilterSelected: (filter) {
              setState(() {
                selectedFilter = filter;
              });
            },
            onIngredientEntered: (ing) {
              setState(() {
                ingredient = ing;
              });
            },
            onSave: () {
              // This method will add a new filter to the list
              setState(() {
                filters.add(FilterOption(
                  type: selectedFilter, // Use selected filter type
                  value: ingredient, // Use the entered ingredient
                ));
                _onFilterChanged();
              });
            }

            // add new filter option to the option list
            );
      },
    );
  }

  void deleteFilter(FilterOption filter) {
    setState(() {
      filters.remove(filter);
    });
    _onFilterChanged();
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<RecipeFilterOptionsProvider>(context, listen: false);

    filters = filterProvider.filterOptions;
    recipeNameFilter = filterProvider.recipeName;
    _recipesFuture = filterProvider.recipes;

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
                  onChanged: (value) => _onSearchChanged(), // value is linked through the controller inside the init function.
                ),
              ),
              SizedBox(
                width: 16,
              ),
              ElevatedButton(
                  onPressed: () => _showFilterPopup(context),
                  child: Icon(Icons.filter_alt)),
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
                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft, // Center the entire Wrap
                        child: Wrap(
                          spacing: 0, // Horizontal space between chips
                          runSpacing: 0, // Vertical space between rows
                          alignment: WrapAlignment.start, // Center items in each row
                          children: filters.map((filter) {
                            return FilterOptionChip(
                              filter: filter,
                              onDelete: () => deleteFilter(filter),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
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
                          // _searchController.clear();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateRecipeScreen(
                                      preloadedRecipeName: query)));
                        },
                        child: const Text('Maak een recept aan'),
                      ),
                    ],
                  );
                } else {
                  final recipes = snapshot.data!;
                  return CustomScrollView(
                    slivers: [
                      // Sliver that contains the Wrap (it will scroll with the rest)
                      SliverToBoxAdapter(
                        child: Align(
                          alignment: Alignment.centerLeft, // Center the entire Wrap
                          child: Wrap(
                            spacing: 0, // Horizontal space between chips
                            runSpacing: 0, // Vertical space between rows
                            alignment: WrapAlignment.start, // Center items in each row
                            children: filters.map((filter) {
                              return FilterOptionChip(
                                filter: filter,
                                onDelete: () => deleteFilter(filter),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 8.0), // Space between the Wrap and the ListView
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
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      String query = _searchController.text;
                                      _searchController.clear();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CreateRecipeScreen(
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
                                score: recipes[index].score,
                                isFavorited: recipes[index].isFavorited,
                                imageUrl: recipes[index].imagePath,
                                onFavoriteToggle: () {
                                  setState(() {
                                    recipes[index].isFavorited = !recipes[index].isFavorited;
                                  });
                                },
                              );
                            }
                          },
                          childCount: recipes.length + 1,
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

class FilterPopup extends StatelessWidget {
  final FilterType initialFilter;
  final String initialIngredient;
  final ValueChanged<FilterType> onFilterSelected;
  final ValueChanged<String> onIngredientEntered;
  final VoidCallback onSave;

  const FilterPopup({
    super.key,
    required this.initialFilter,
    required this.initialIngredient,
    required this.onFilterSelected,
    required this.onIngredientEntered,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    FilterType tempFilter = initialFilter;
    String tempIngredient = initialIngredient;
    FocusNode dropdownFocusNode = FocusNode();

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text('Filter Opties'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<FilterType>(
                focusNode: dropdownFocusNode,
                value: tempFilter,
                decoration: InputDecoration(
                  labelText: 'Filter Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  FilterType.select,
                  FilterType.ingredient,
                ]
                    .map((filterType) => DropdownMenuItem<FilterType>(
                          value: filterType,
                          child: Text(filterType.description),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    tempFilter = value!;
                  });
                  FocusScope.of(context).requestFocus(FocusNode());
                },
              ),
              SizedBox(height: 16),
              _buildFilterOptions(tempFilter, tempIngredient, (newValue) {
                tempIngredient = newValue;
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Annuleer'),
            ),
            TextButton(
              onPressed: tempFilter != FilterType.select
                  ? () {
                      onFilterSelected(tempFilter);
                      onIngredientEntered(tempIngredient);
                      onSave();
                      Navigator.pop(context); // Close the dialog
                    }
                  : null, // Disable OK if invalid
              child: Text(
                'OK',
                style: TextStyle(
                  color: tempFilter != FilterType.select
                      ? Theme.of(context).primaryColor
                      : Colors.grey, // Visual feedback for disabled button
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOptions(
    FilterType filterType,
    String currentIngredient,
    ValueChanged<String> onIngredientChanged,
  ) {
    switch (filterType) {
      case FilterType.ingredient:
        return TextField(
          decoration: InputDecoration(
            labelText: FilterType.ingredient.description,
            border: OutlineInputBorder(),
          ),
          onChanged: onIngredientChanged,
        );
      default:
        return Container(); // Empty widget for unsupported or default options
    }
  }
}

class FilterOptionChip extends StatelessWidget {
  final FilterOption filter;
  final VoidCallback onDelete;

  const FilterOptionChip({
    super.key,
    required this.filter,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    var backgroundColor = Theme.of(context).colorScheme.primaryContainer;
    var textColor = Theme.of(context).colorScheme.onPrimaryContainer;
    var borderColor = Theme.of(context).colorScheme.secondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: Chip(

        label: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center, // Aligns children vertically
          children: [
            Icon(
              getFilterIcon(filter.type),
              size: 20.0, // Adjust icon size
              color: textColor,
            ),
            SizedBox(width: 8.0), // Space between icon and text
            Text(filter.value),
          ],
        ),
        deleteIcon: Icon(Icons.close,
            color: textColor),
        onDeleted: onDelete,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor, width: 2),
          // Set the border color
          borderRadius: BorderRadius.circular(
              20),
        ),
        deleteIconColor: Colors.white,
        labelStyle: TextStyle(
            color: textColor),
      ),
    );
  }
}
