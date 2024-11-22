import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/models/recipes/recipe_filter.dart';
import 'package:frontend/models/recipes/recipe_type.dart';
import 'package:frontend/screens/create_recipe_screen.dart';
import 'package:frontend/state/recipe_filter_options_provider.dart';
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

  FilterType selectedFilter = FilterType.select;
  String ingredientFilter = '';

  List<FilterOption> filters = [];
  String recipeNameFilter = "";
  RecipeType recipeTypeFilter = RecipeType.snack;

  @override
  void initState() {
    super.initState();

    // Initialize TextEditingController with the current value of recipenamefilter
    final filterProvider =
        Provider.of<RecipeFilterOptionsProvider>(context, listen: false);
    _searchController = TextEditingController(text: filterProvider.recipeName);

    // Listen to TextEditingController changes and update the provider
    _searchController.addListener(() {
      filterProvider.recipeName = _searchController.text;
    });
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
            initialRecipeType: RecipeType.snack,
            onFilterSelected: (filter) {
              setState(() {
                selectedFilter = filter;
              });
            },
            onIngredientEntered: (ing) {
              setState(() {
                ingredientFilter = ing;
              });
            },
            onRecipeTypeSelected: (recipeType) {
              setState(() {
                recipeTypeFilter = recipeType;
              });
            },
            onSave: () {
              // This method will add a new filter to the list
              setState(() {
                filters.add(FilterOption(
                  type: selectedFilter, // Use selected filter type
                  value: switch (selectedFilter) {
                    FilterType.ingredient => ingredientFilter,
                    FilterType.mealType => recipeTypeFilter.index.toString(),
                    // Add other cases here if needed
                    _ => "", // Handle default case gracefully
                  },
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
    final filterProvider =
        Provider.of<RecipeFilterOptionsProvider>(context, listen: false);

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
                  onChanged: (value) =>
                      _onSearchChanged(), // value is linked through the controller inside the init function.
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
                        alignment: Alignment.centerLeft,
                        // Center the entire Wrap
                        child: Wrap(
                          spacing: 0,
                          // Horizontal space between chips
                          runSpacing: 0,
                          // Vertical space between rows
                          alignment: WrapAlignment.start,
                          // Center items in each row
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
                          alignment: Alignment.centerLeft,
                          // Center the entire Wrap
                          child: Wrap(
                            spacing: 0,
                            // Horizontal space between chips
                            runSpacing: 0,
                            // Vertical space between rows
                            alignment: WrapAlignment.start,
                            // Center items in each row
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
                                isFavorited: recipes[index].isFavorited,
                                imageUrl: recipes[index].imagePath,
                                onFavoriteToggle: () {
                                  setState(() {
                                    recipes[index].isFavorited =
                                        !recipes[index].isFavorited;
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

class FilterPopup extends StatelessWidget {
  final FilterType initialFilter;
  final String initialIngredient;
  final RecipeType initialRecipeType;
  final ValueChanged<FilterType> onFilterSelected;
  final ValueChanged<String> onIngredientEntered;
  final ValueChanged<RecipeType> onRecipeTypeSelected;
  final VoidCallback onSave;

  const FilterPopup({
    super.key,
    required this.initialFilter,
    required this.initialIngredient,
    required this.initialRecipeType,
    required this.onFilterSelected,
    required this.onIngredientEntered,
    required this.onRecipeTypeSelected,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    FilterType tempFilter = initialFilter;
    String tempIngredient = initialIngredient;
    RecipeType tempMealType = initialRecipeType;
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
                  FilterType.mealType,
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
              _buildFilterOptions(
                  tempFilter,
                  tempIngredient,
                  (newValue) {
                    tempIngredient = newValue;
                  },
                  tempMealType,
                  (newValue) {
                    tempMealType = newValue;
                  },
                  dropdownFocusNode,
                  context),
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
                      onRecipeTypeSelected(tempMealType);
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
    RecipeType selectedRecipeType,
    ValueChanged<RecipeType> onRecipeTypeChanged,
    FocusNode dropdownFocusNode,
    BuildContext context,
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
      case FilterType.mealType:
        return DropdownButtonFormField<RecipeType>(
          focusNode: dropdownFocusNode,
          value: selectedRecipeType,
          decoration: InputDecoration(
            labelText: "Select Recipe Type",
            border: OutlineInputBorder(),
          ),
          items: RecipeType.values
              .where((type) => type != RecipeType.notAvailable)
              .map((type) {
            return DropdownMenuItem<RecipeType>(
              value: type,
              child: Text(recipeTypeToStringNl(type)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onRecipeTypeChanged(value);
            }
            FocusScope.of(context).requestFocus(FocusNode());
          },
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

  getFilterText() {
    return switch (filter.type) {
      FilterType.mealType => recipeTypeToStringNlFromIntString(filter.value),
      FilterType.cookTime => "${filter.value}'",
      _ => filter.value
    };
  }

  @override
  Widget build(BuildContext context) {
    var backgroundColor = Theme.of(context).colorScheme.primaryContainer;
    var textColor = Theme.of(context).colorScheme.onPrimaryContainer;
    var borderColor = Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: Chip(
        label: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          // Aligns children vertically
          children: [
            Icon(
              getFilterIcon(filter.type),
              size: 20.0, // Adjust icon size
              color: textColor,
            ),
            SizedBox(width: 8.0), // Space between icon and text
            Text(getFilterText()),
          ],
        ),
        deleteIcon: Icon(Icons.close, color: textColor),
        onDeleted: onDelete,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor, width: 2),
          // Set the border color
          borderRadius: BorderRadius.circular(20),
        ),
        deleteIconColor: Colors.white,
        labelStyle: TextStyle(color: textColor),
      ),
    );
  }
}
