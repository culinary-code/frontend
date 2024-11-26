import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/difficulty.dart';
import 'package:frontend/models/recipes/recipe_filter.dart';
import 'package:frontend/models/recipes/recipe_type.dart';

class FilterPopup extends StatelessWidget {
  final FilterType initialFilter;
  final String initialIngredient;
  final RecipeType initialRecipeType;
  final Difficulty initialDifficulty;
  final String initialCookTime;
  final ValueChanged<FilterType> onFilterSelected;
  final ValueChanged<String> onIngredientEntered;
  final ValueChanged<RecipeType> onRecipeTypeSelected;
  final ValueChanged<Difficulty> onDifficultySelected;
  final ValueChanged<String> onCookTimeEntered;
  final VoidCallback onSave;

  const FilterPopup({
    super.key,
    required this.initialFilter,
    required this.initialIngredient,
    required this.initialRecipeType,
    required this.initialDifficulty,
    required this.initialCookTime,
    required this.onFilterSelected,
    required this.onIngredientEntered,
    required this.onRecipeTypeSelected,
    required this.onDifficultySelected,
    required this.onCookTimeEntered,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    FilterType tempFilter = initialFilter;
    String tempIngredient = initialIngredient;
    RecipeType tempMealType = initialRecipeType;
    Difficulty tempDifficulty = initialDifficulty;
    String tempCookTime = initialCookTime;
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
                  FilterType.difficulty,
                  FilterType.cookTime
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
                  tempDifficulty,
                      (newValue) {
                    tempDifficulty = newValue;
                  },
                  tempCookTime,
                      (newValue) {
                    tempCookTime = newValue;
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
                onDifficultySelected(tempDifficulty);
                onCookTimeEntered(tempCookTime);
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
      Difficulty selectedDifficulty,
      ValueChanged<Difficulty> onDifficultyChanged,
      String currentCookTime,
      ValueChanged<String> onCookTimeChanged,
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
            labelText: "Selecteer Recepttype",
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
      case FilterType.difficulty:
        return DropdownButtonFormField<Difficulty>(
          focusNode: dropdownFocusNode,
          value: selectedDifficulty,
          decoration: InputDecoration(
            labelText: "Selecteer moeilijkheid",
            border: OutlineInputBorder(),
          ),
          items: Difficulty.values
              .where((difficulty) => difficulty != Difficulty.notAvailable)
              .map((difficulty) {
            return DropdownMenuItem<Difficulty>(
              value: difficulty,
              child: Text(difficultyToStringNl(difficulty)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onDifficultyChanged(value);
            }
            FocusScope.of(context).requestFocus(FocusNode());
          },
        );
      case FilterType.cookTime:
        return TextField(
          decoration: InputDecoration(
            labelText: FilterType.cookTime.description,
            border: OutlineInputBorder(),
          ),
          onChanged: onCookTimeChanged,
        );
      default:
        return Container(); // Empty widget for unsupported or default options
    }
  }
}