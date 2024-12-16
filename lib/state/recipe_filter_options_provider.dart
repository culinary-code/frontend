import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/difficulty.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/models/recipes/recipe_filter.dart';
import 'package:frontend/models/recipes/recipe_type.dart';
import 'package:frontend/services/recipe_service.dart';

class RecipeFilterOptionsProvider with ChangeNotifier {
  final List<FilterOption> _filterOptions = [];
  String _recipeName = "";
  late Future<List<Recipe>> _recipes;

  FilterType _selectedFilter = FilterType.select;
  String _ingredientFilter = '';
  RecipeType _recipeTypeFilter = RecipeType.snack;
  Difficulty _recipeDifficultyFilter = Difficulty.easy;
  String _cookTimeFilter = '';

  // getters
  List<FilterOption> get filterOptions => _filterOptions;

  String get recipeName => _recipeName;

  Future<List<Recipe>> get recipes => _recipes;

  FilterType get selectedFilter => _selectedFilter;

  String get ingredientFilter => _ingredientFilter;

  RecipeType get recipeTypeFilter => _recipeTypeFilter;

  Difficulty get recipeDifficultyFilter => _recipeDifficultyFilter;

  String get cookTimeFilter => _cookTimeFilter;

  //setters
  set recipeName(String newName) {
    _recipeName = newName;
    notifyListeners();
  }

  set recipes(Future<List<Recipe>> newRecipes) {
    _recipes = newRecipes;
    notifyListeners();
  }

  void addFilterOption(FilterOption filterOption) {
    _filterOptions.add(filterOption);
    notifyListeners();
  }

  void removeItem(FilterOption filterOption) {
    _filterOptions.remove(filterOption);
    notifyListeners();
  }

  set selectedFilter(FilterType filterType) {
    _selectedFilter = filterType;
    notifyListeners();
  }

  set ingredientFilter(String newIngredient) {
    _ingredientFilter = newIngredient;
    notifyListeners();
  }

  set recipeTypeFilter(RecipeType recipeType) {
    _recipeTypeFilter = recipeType;
    notifyListeners();
  }

  set recipeDifficultyFilter(Difficulty difficulty) {
    _recipeDifficultyFilter = difficulty;
    notifyListeners();
  }

  set cookTimeFilter(String newCookTime) {
    _cookTimeFilter = newCookTime;
    notifyListeners();
  }

  void onFilterChanged(BuildContext context) {
    if (_recipeName.isNotEmpty || _filterOptions.isNotEmpty) {
      recipes = RecipeService().getFilteredRecipes(context, _recipeName, _filterOptions);
    } else {
      recipes = RecipeService().getRecipes(context);
    }
    notifyListeners();
  }

  void removeExistingFilter(FilterType selectedFilter) {
    filterOptions.removeWhere((filter) => filter.type == selectedFilter);
    notifyListeners();
  }

  void deleteFilter(BuildContext context, FilterOption filter) {
    filterOptions.remove(filter);
    onFilterChanged(context);
  }

  void clearFilters(BuildContext context) {
    _recipeName = '';
    _filterOptions.clear();
    _ingredientFilter = '';
    _recipeTypeFilter = RecipeType.snack;
    _recipeDifficultyFilter = Difficulty.easy;
    _cookTimeFilter = '';
    onFilterChanged(context);
  }
}
