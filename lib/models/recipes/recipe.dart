import 'package:frontend/models/accounts/preference.dart';
import 'package:frontend/models/accounts/review.dart';
import 'package:frontend/models/recipes/favorite_recipe.dart';
import 'package:frontend/models/recipes/ingredients/ingredient_quantity.dart';
import 'package:frontend/models/recipes/instruction_step.dart';
import 'package:frontend/models/recipes/recipe_type.dart';
import 'package:frontend/models/recipes/difficulty.dart';
import 'package:frontend/models/meal_planning/PlannedMeal.dart';

class Recipe {
  final String recipeId;
  final String recipeName;
  final double score;
  bool isFavorited;

  final List<IngredientQuantity> ingredients;
  final List<Preference> preferences;
  final RecipeType recipeType;
  final String description;
  final int cookingTime;
  final int amountOfPeople;
  final Difficulty difficulty;
  final String imagePath;
  final DateTime createdAt;
  final List<InstructionStep> instructions;
  final List<Review> reviews;

  // navigation properties
  final List<PlannedMeal> plannedMeals;
  final List<FavoriteRecipe> favoriteRecipes;

  Recipe(
      {required this.recipeId,
      required this.recipeName,
      this.score = 0.0,
      this.isFavorited = false,
      this.ingredients = const [],
      this.preferences = const [],
      required this.recipeType,
      required this.description,
      required this.cookingTime,
      required this.amountOfPeople,
      required this.difficulty,
      this.imagePath = "",
      required this.createdAt,
      this.instructions = const [],
      this.reviews = const [],
      this.plannedMeals = const [],
      this.favoriteRecipes = const []});

  static List<Recipe> recipeList() {
    return [
      Recipe(
        recipeName: "Puree met spinazie",
        imagePath: "https://picsum.photos/300/300",
        score: 5.0,
        isFavorited: false,
        recipeId: "1",
        recipeType: RecipeType.dinner,
        description: "Puree met spinazie",
        cookingTime: 30,
        amountOfPeople: 4,
        difficulty: Difficulty.easy,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Friet met stoofvlees, mayonaise en een hartig witloofslaatje met mosterddressing",
        imagePath: "https://picsum.photos/300/300",
        score: 4.6,
        isFavorited: true,
        recipeId: "2",
        recipeType: RecipeType.dinner,
        description: "Friet met stoofvlees",
        cookingTime: 60,
        amountOfPeople: 4,
        difficulty: Difficulty.intermediate,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Aardappelgratin met bechamelsaus",
        imagePath: "https://picsum.photos/300/300",
        score: 4.1,
        recipeId: "3",
        recipeType: RecipeType.dinner,
        description: "Aardappelgratin met bechamelsaus",
        cookingTime: 45,
        amountOfPeople: 4,
        difficulty: Difficulty.intermediate,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Garnaalkroketten",
        imagePath: "https://picsum.photos/300/300",
        score: 0.0,
        isFavorited: true,
        recipeId: "4",
        recipeType: RecipeType.dinner,
        description: "Garnaalkroketten",
        cookingTime: 30,
        amountOfPeople: 4,
        difficulty: Difficulty.difficult,
        createdAt: DateTime.now(),
      )
    ];
  }
}
