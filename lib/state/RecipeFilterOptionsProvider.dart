import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/models/recipes/recipe_filter.dart';
import 'package:frontend/services/recipe_service.dart';

class RecipeFilterOptionsProvider with ChangeNotifier {
  List<FilterOption> _filterOptions = [];
  String _recipeName = "";
  late Future<List<Recipe>> _recipes ;

  List<FilterOption> get filterOptions => _filterOptions;
  String get recipeName => _recipeName;
  Future<List<Recipe>> get recipes => _recipes;

  RecipeFilterOptionsProvider(){
    _recipes = RecipeService().getRecipes();
  }

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


  void onFilterChanged() {
    if (_recipeName.isNotEmpty || _filterOptions.isNotEmpty){
      recipes =
          RecipeService().getFilteredRecipes(_recipeName, _filterOptions);
    }
    else {
      recipes = RecipeService().getRecipes();
    }
  }

}