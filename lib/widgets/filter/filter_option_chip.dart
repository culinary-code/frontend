import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/difficulty.dart';
import 'package:frontend/models/recipes/recipe_filter.dart';
import 'package:frontend/models/recipes/recipe_type.dart';

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
      FilterType.difficulty => recipeDifficultyToStringNlFromIntString(filter.value),
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