import 'dart:convert';
import 'package:frontend/models/recipes/recipe_filter.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/models/recipes/recipe.dart';

class RecipeService {
  Future<List<Recipe>> getRecipes() async {
    final String searchQuery = "o";
    final String searchEndpoint = "Recipe/Collection/ByName/$searchQuery";

    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet(searchEndpoint);

    if (response.statusCode != 200) {
      throw FormatException('Failed to load recipes: ${response.body}');
    }

    final List<dynamic> dynamicRecipes = json.decode(response.body);

    final List<Recipe> recipes = dynamicRecipes
        .map((dynamic recipe) => Recipe.fromJson(recipe))
        .toList();

    return recipes;
  }

  Future<List<Recipe>> getFilteredRecipes(
      String recipename, List<FilterOption> filterOptions) async {
    final String searchEndpoint = "Recipe/Collection/Filtered";

    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedPost(searchEndpoint,
        _buildFilterOptionPayload(recipename, filterOptions));

    if (response.statusCode != 200) {
      throw FormatException('Failed to load recipes: ${response.body}');
    }

    final List<dynamic> dynamicRecipes = json.decode(response.body);

    final List<Recipe> recipes = dynamicRecipes
        .map((dynamic recipe) => Recipe.fromJson(recipe))
        .toList();

    return recipes;
  }

  Future<List<Recipe>> getRecipesByName(String query) async {
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet('Recipe/Collection/ByName/$query');

    if (response.statusCode == 404) {
      return [];
    } else if (response.statusCode != 200) {
      throw FormatException('Failed to load recipes: ${response.body}');
    }

    final List<dynamic> dynamicRecipes = json.decode(response.body);

    final List<Recipe> recipes = dynamicRecipes.map((dynamic recipe) => Recipe.fromJson(recipe)).toList();

    return recipes;
  }

  Future<Recipe> getRecipeById(String id) async {
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet('Recipe/$id');

    if (response.statusCode != 200) {
      throw FormatException('Failed to load recipe: ${response.body}');
    }

    final dynamic recipe = json.decode(response.body);

    return Recipe.fromJson(recipe);
  }

  Future<String> createRecipe(String recipename, List<FilterOption> filterOptions) async {
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedPost('Recipe/Create',
        _buildFilterOptionPayload(recipename, filterOptions));

    if (response.statusCode == 400) {
      return response.body;
    }

    if (response.statusCode != 200) {
      throw FormatException('Failed to create recipe: ${response.body}');
    }

    if (response.statusCode == 200) {
      final dynamic recipe = json.decode(response.body);

      return recipe['recipeId'];
    }

    return '';
  }

  Map<String, dynamic> _buildFilterOptionPayload(String recipename, List<FilterOption> filterOptions) {

    List<String> ingredients = [];
    var difficulty = "";
    var cooktime = 0;
    var mealtype = "";

    for (var option in filterOptions) {
      switch (option.type) {
        case FilterType.ingredient:
          ingredients.add(option.value);
        case FilterType.difficulty:
          difficulty = option.value;
        case FilterType.cookTime:
          cooktime = int.parse(
              option.value);
        case FilterType.mealType:
          mealtype = option.value;
        default:
      }
    }

    return {
      "RecipeName": recipename,
      "Ingredients": ingredients,
      "Difficulty": difficulty,
      "CookTime": cooktime,
      "MealType": mealtype,
    };
  }
}
