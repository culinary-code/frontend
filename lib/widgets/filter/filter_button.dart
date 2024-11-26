import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/difficulty.dart';
import 'package:frontend/models/recipes/recipe_filter.dart';
import 'package:frontend/models/recipes/recipe_type.dart';
import 'package:frontend/state/recipe_filter_options_provider.dart';
import 'package:frontend/widgets/filter/filter_popup.dart';
import 'package:provider/provider.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showFilterDialog(context),
      child: const Icon(Icons.filter_alt),
    );
  }
}

// Reusable function to show the filter dialog
Future<void> showFilterDialog(BuildContext context) {
  final filterProvider = Provider.of<RecipeFilterOptionsProvider>(context, listen: false);

  return showDialog(
    context: context,
    builder: (context) {
      return FilterPopup(
        initialFilter: FilterType.select,
        initialIngredient: '',
        initialRecipeType: RecipeType.snack,
        initialDifficulty: Difficulty.easy,
        initialCookTime: "0",
        onFilterSelected: (filter) {
          filterProvider.selectedFilter = filter;
        },
        onIngredientEntered: (ing) {
          filterProvider.ingredientFilter = ing;
        },
        onRecipeTypeSelected: (recipeType) {
          filterProvider.recipeTypeFilter = recipeType;
        },
        onDifficultySelected: (difficulty) {
          filterProvider.recipeDifficultyFilter = difficulty;
        },
        onCookTimeEntered: (cooktime) {
          filterProvider.cookTimeFilter = cooktime;
        },
        onSave: () {
          if (filterProvider.selectedFilter != FilterType.ingredient) filterProvider.removeExistingFilter(filterProvider.selectedFilter);

          // add the new filteroption
          filterProvider.filterOptions.add(FilterOption(
            type: filterProvider.selectedFilter, // Use selected filter type
            value: switch (filterProvider.selectedFilter) {
              FilterType.ingredient => filterProvider.ingredientFilter,
              FilterType.mealType => filterProvider.recipeTypeFilter.index.toString(),
              FilterType.difficulty => filterProvider.recipeDifficultyFilter.index.toString(),
              FilterType.cookTime => filterProvider.cookTimeFilter,
            // Add other cases here if needed
              _ => "", // Handle default case gracefully
            },
          ));

          // rerender the filteroptions
          filterProvider.onFilterChanged();
        },
      );
    },
  );
}