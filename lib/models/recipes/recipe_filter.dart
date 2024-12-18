import 'package:flutter/material.dart';

enum FilterType { select, ingredient, difficulty, cookTime, mealType }

extension FilterTypeExtension on FilterType {
  String get description {
    switch (this) {
      case FilterType.select:
        return "Selecteer je filter";
      case FilterType.ingredient:
        return "Ingrediëntnaam";
      case FilterType.difficulty:
        return "Moeilijkheidsgraad";
      case FilterType.cookTime:
        return "Kooktijd";
      case FilterType.mealType:
        return "Maaltijdtype";
    }
  }
}

class FilterOption {
  final String value;
  final FilterType type;

  FilterOption({required this.value, required this.type});
}


IconData getFilterIcon(FilterType type) {
  switch (type) {
    case FilterType.ingredient:
      return Icons.local_grocery_store_outlined;
    case FilterType.difficulty:
      return Icons.star_outline_outlined;
    case FilterType.cookTime:
      return Icons.access_time_outlined;
    case FilterType.mealType:
      return Icons.local_dining_outlined;
    default:
      return Icons.settings;
  }
}
