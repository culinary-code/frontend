import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/difficulty.dart';
import 'package:frontend/models/recipes/recipe_filter.dart';
import 'package:frontend/models/recipes/recipe_type.dart';
import 'package:frontend/state/recipe_filter_options_provider.dart';
import 'package:provider/provider.dart';

class FilterOptionChip extends StatelessWidget {
  // Existing fields
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
      FilterType.difficulty =>
        recipeDifficultyToStringNlFromIntString(filter.value),
      FilterType.cookTime => "${filter.value}'",
      _ => filter.value
    };
  }

  // Helper method for consistent chip style
  static Chip buildStyledChip({
    required Widget label,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    VoidCallback? onDeleted,
  }) {
    return Chip(
      label: label,
      deleteIcon:
          onDeleted != null ? Icon(Icons.close, color: textColor) : null,
      onDeleted: onDeleted,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor ?? Colors.transparent, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      labelStyle: TextStyle(color: textColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    var backgroundColor = Theme.of(context).colorScheme.primaryContainer;
    var textColor = Theme.of(context).colorScheme.onPrimaryContainer;
    var borderColor = Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: buildStyledChip(
        label: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(
              getFilterIcon(filter.type),
              size: 20.0,
              color: textColor,
            ),
            SizedBox(width: 8.0),
            Text(getFilterText()),
          ],
        ),
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderColor: borderColor,
        onDeleted: onDelete,
      ),
    );
  }
}

class FilterOptionsDisplayWidget extends StatefulWidget {
  final VoidCallback onDelete;
  const FilterOptionsDisplayWidget({
    super.key, required this.onDelete,
  });

  @override
  FilterOptionsDisplayWidgetState createState() =>
      FilterOptionsDisplayWidgetState();
}

class FilterOptionsDisplayWidgetState
    extends State<FilterOptionsDisplayWidget> {
  bool showAllFilterOptions = false;

  @override
  Widget build(BuildContext context) {
    final filterProvider =
        Provider.of<RecipeFilterOptionsProvider>(context, listen: true);
    final hiddenCount = filterProvider.filterOptions.length > 3
        ? filterProvider.filterOptions.length - 3
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            // Center the entire Wrap
            child: Wrap(
              spacing: 8, // Add spacing between items
              runSpacing: 0, // Add vertical spacing between rows
              alignment: WrapAlignment.start,
              children: [
                ...filterProvider.filterOptions
                    .take(showAllFilterOptions
                        ? filterProvider.filterOptions.length
                        : 3)
                    .map((filter) {
                  return FilterOptionChip(
                    filter: filter,
                    onDelete: () => setState(() {
                      filterProvider.deleteFilter(context, filter);
                      widget.onDelete();
                    }),
                  );
                }),
                if (!showAllFilterOptions && hiddenCount > 0)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAllFilterOptions = true; // Expand to show all
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 2),
                      child: FilterOptionChip.buildStyledChip(
                        label: Text('+$hiddenCount more'),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        textColor:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        borderColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
              ],
            )),
        if (showAllFilterOptions)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                setState(() {
                  showAllFilterOptions =
                      !showAllFilterOptions; // Toggle the `showAll` state
                });
              },
              child: Text('Show Less'),
            ),
          ),
      ],
    );
  }
}
