import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/difficulty.dart';
import 'package:frontend/models/recipes/recipe_filter.dart';
import 'package:frontend/models/recipes/recipe_type.dart';

class FilterPopup extends StatefulWidget {
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
  FilterPopupState createState() => FilterPopupState();
}

class FilterPopupState extends State<FilterPopup> {
  late FilterType tempFilter;
  late String tempIngredient;
  late RecipeType tempMealType;
  late Difficulty tempDifficulty;
  late String tempCookTime;
  late double cookTimeValue;

  @override
  void initState() {
    super.initState();
    // Initialize the states with the initial values
    tempFilter = widget.initialFilter;
    tempIngredient = widget.initialIngredient;
    tempMealType = widget.initialRecipeType;
    tempDifficulty = widget.initialDifficulty;
    tempCookTime = widget.initialCookTime;
    cookTimeValue = double.tryParse(tempCookTime) ?? 30;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter Opties'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<FilterType>(
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
            },
          ),
          SizedBox(height: 16),
          _buildFilterOptions(
            tempFilter,
            tempIngredient,
            (newValue) {
              setState(() {
                tempIngredient = newValue;
              });
            },
            tempMealType,
            (newValue) {
              setState(() {
                tempMealType = newValue;
              });
            },
            tempDifficulty,
            (newValue) {
              setState(() {
                tempDifficulty = newValue;
              });
            },
            tempCookTime,
            (newValue) {
              setState(() {
                tempCookTime = newValue;
              });
            },
            context,
          ),
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
                  widget.onFilterSelected(tempFilter);
                  widget.onIngredientEntered(tempIngredient);
                  widget.onRecipeTypeSelected(tempMealType);
                  widget.onDifficultySelected(tempDifficulty);
                  widget.onCookTimeEntered(tempCookTime);
                  widget.onSave();
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
          },
        );
      case FilterType.difficulty:
        return DropdownButtonFormField<Difficulty>(
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
          },
        );
      case FilterType.cookTime:
        return Column(
          children: [
            Text('${cookTimeValue.toInt()} min'),
            Slider(
              value: cookTimeValue,
              min: 10,
              max: 240,
              divisions: 23,
              // Display the current value of the slider
              onChanged: (value) {
                setState(() {
                  cookTimeValue = value;
                  tempCookTime = value.toStringAsFixed(
                      0); // Update tempCookTime with the slider value
                });
                onCookTimeChanged(
                    tempCookTime); // Call the parent callback with the new value
              },
            )
          ],
        );

      default:
        return Container();
    }
  }
}
