import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/recipe_filter.dart';

class RecipeFilterOptionsProvider with ChangeNotifier {
  List<FilterOption> _filterOptions = [];

  List<FilterOption> get filterOptions => _filterOptions;

  void addFilterOption(FilterOption filterOption) {
    _filterOptions.add(filterOption);
    notifyListeners();
  }

  void removeItem(FilterOption filterOption) {
    _filterOptions.remove(filterOption);
    notifyListeners();
  }
}