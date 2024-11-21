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
  final List<PlannedMealReduced> plannedMeals;
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
        isFavorited: false,
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
      ),
      Recipe(
        recipeName: "Pasta Carbonara",
        imagePath: "https://picsum.photos/300/300",
        score: 4.8,
        isFavorited: false,
        recipeId: "5",
        recipeType: RecipeType.dinner,
        description: "Classic Italian pasta carbonara with creamy sauce",
        cookingTime: 20,
        amountOfPeople: 2,
        difficulty: Difficulty.easy,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Spaghetti Bolognese",
        imagePath: "https://picsum.photos/300/300",
        score: 4.7,
        isFavorited: true,
        recipeId: "6",
        recipeType: RecipeType.dinner,
        description: "Rich and hearty spaghetti Bolognese with beef",
        cookingTime: 40,
        amountOfPeople: 4,
        difficulty: Difficulty.intermediate,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Caesar Salad",
        imagePath: "https://picsum.photos/300/300",
        score: 4.3,
        isFavorited: false,
        recipeId: "7",
        recipeType: RecipeType.lunch,
        description: "Fresh Caesar salad with chicken and croutons",
        cookingTime: 15,
        amountOfPeople: 2,
        difficulty: Difficulty.easy,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Vegetarian Quiche",
        imagePath: "https://picsum.photos/300/300",
        score: 4.5,
        isFavorited: true,
        recipeId: "8",
        recipeType: RecipeType.dinner,
        description: "Quiche with spinach, mushrooms, and cheese",
        cookingTime: 45,
        amountOfPeople: 4,
        difficulty: Difficulty.intermediate,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "French Onion Soup",
        imagePath: "https://picsum.photos/300/300",
        score: 4.0,
        isFavorited: false,
        recipeId: "9",
        recipeType: RecipeType.lunch,
        description: "Savory soup with caramelized onions and cheese",
        cookingTime: 50,
        amountOfPeople: 4,
        difficulty: Difficulty.difficult,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Chicken Stir Fry",
        imagePath: "https://picsum.photos/300/300",
        score: 4.6,
        isFavorited: false,
        recipeId: "10",
        recipeType: RecipeType.dinner,
        description: "Quick and easy chicken stir fry with vegetables",
        cookingTime: 25,
        amountOfPeople: 3,
        difficulty: Difficulty.easy,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Beef Stew",
        imagePath: "https://picsum.photos/300/300",
        score: 4.2,
        isFavorited: true,
        recipeId: "11",
        recipeType: RecipeType.dinner,
        description: "Slow-cooked beef stew with potatoes and carrots",
        cookingTime: 120,
        amountOfPeople: 6,
        difficulty: Difficulty.difficult,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Salmon with Asparagus",
        imagePath: "https://picsum.photos/300/300",
        score: 4.9,
        isFavorited: true,
        recipeId: "12",
        recipeType: RecipeType.dinner,
        description: "Grilled salmon served with fresh asparagus",
        cookingTime: 25,
        amountOfPeople: 2,
        difficulty: Difficulty.intermediate,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Shrimp Tacos",
        imagePath: "https://picsum.photos/300/300",
        score: 4.4,
        isFavorited: false,
        recipeId: "13",
        recipeType: RecipeType.dinner,
        description: "Flavorful shrimp tacos with lime and salsa",
        cookingTime: 30,
        amountOfPeople: 4,
        difficulty: Difficulty.easy,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Minestrone Soup",
        imagePath: "https://picsum.photos/300/300",
        score: 4.1,
        isFavorited: false,
        recipeId: "14",
        recipeType: RecipeType.lunch,
        description: "Hearty Italian minestrone soup with beans",
        cookingTime: 35,
        amountOfPeople: 4,
        difficulty: Difficulty.intermediate,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Chicken Parmesan",
        imagePath: "https://picsum.photos/300/300",
        score: 5.0,
        isFavorited: true,
        recipeId: "15",
        recipeType: RecipeType.dinner,
        description: "Classic chicken Parmesan with marinara sauce",
        cookingTime: 45,
        amountOfPeople: 4,
        difficulty: Difficulty.intermediate,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Eggplant Parmesan",
        imagePath: "https://picsum.photos/300/300",
        score: 4.3,
        isFavorited: false,
        recipeId: "16",
        recipeType: RecipeType.dinner,
        description: "Vegetarian eggplant Parmesan with mozzarella",
        cookingTime: 50,
        amountOfPeople: 4,
        difficulty: Difficulty.difficult,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Lamb Chops with Mint",
        imagePath: "https://picsum.photos/300/300",
        score: 4.8,
        isFavorited: true,
        recipeId: "17",
        recipeType: RecipeType.dinner,
        description: "Grilled lamb chops with a fresh mint sauce",
        cookingTime: 30,
        amountOfPeople: 2,
        difficulty: Difficulty.intermediate,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Vegetable Stir Fry",
        imagePath: "https://picsum.photos/300/300",
        score: 4.0,
        isFavorited: false,
        recipeId: "18",
        recipeType: RecipeType.dinner,
        description: "Quick and healthy vegetable stir fry",
        cookingTime: 20,
        amountOfPeople: 2,
        difficulty: Difficulty.easy,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Banana Pancakes",
        imagePath: "https://picsum.photos/300/300",
        score: 4.5,
        isFavorited: true,
        recipeId: "19",
        recipeType: RecipeType.breakfast,
        description: "Fluffy banana pancakes with maple syrup",
        cookingTime: 15,
        amountOfPeople: 2,
        difficulty: Difficulty.easy,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Fish Tacos",
        imagePath: "https://picsum.photos/300/300",
        score: 4.2,
        isFavorited: false,
        recipeId: "20",
        recipeType: RecipeType.dinner,
        description: "Fresh fish tacos with cabbage slaw and lime",
        cookingTime: 25,
        amountOfPeople: 3,
        difficulty: Difficulty.easy,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Chili Con Carne",
        imagePath: "https://picsum.photos/300/300",
        score: 4.6,
        isFavorited: true,
        recipeId: "21",
        recipeType: RecipeType.dinner,
        description: "Spicy chili con carne with beef and beans",
        cookingTime: 60,
        amountOfPeople: 5,
        difficulty: Difficulty.intermediate,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Tomato Basil Pasta",
        imagePath: "https://picsum.photos/300/300",
        score: 4.1,
        isFavorited: false,
        recipeId: "22",
        recipeType: RecipeType.dinner,
        description: "Simple pasta with fresh tomatoes and basil",
        cookingTime: 25,
        amountOfPeople: 3,
        difficulty: Difficulty.easy,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Pulled Pork Sandwich",
        imagePath: "https://picsum.photos/300/300",
        score: 4.8,
        isFavorited: true,
        recipeId: "23",
        recipeType: RecipeType.lunch,
        description: "BBQ pulled pork sandwich with coleslaw",
        cookingTime: 90,
        amountOfPeople: 4,
        difficulty: Difficulty.difficult,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Stuffed Bell Peppers",
        imagePath: "https://picsum.photos/300/300",
        score: 4.4,
        isFavorited: false,
        recipeId: "24",
        recipeType: RecipeType.dinner,
        description: "Bell peppers stuffed with rice and ground beef",
        cookingTime: 60,
        amountOfPeople: 4,
        difficulty: Difficulty.intermediate,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Chicken Alfredo",
        imagePath: "https://picsum.photos/300/300",
        score: 4.7,
        isFavorited: true,
        recipeId: "25",
        recipeType: RecipeType.dinner,
        description: "Creamy chicken Alfredo pasta with garlic",
        cookingTime: 30,
        amountOfPeople: 4,
        difficulty: Difficulty.easy,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Turkey Meatballs",
        imagePath: "https://picsum.photos/300/300",
        score: 4.3,
        isFavorited: false,
        recipeId: "26",
        recipeType: RecipeType.dinner,
        description: "Turkey meatballs in marinara sauce",
        cookingTime: 40,
        amountOfPeople: 4,
        difficulty: Difficulty.intermediate,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Roasted Vegetables",
        imagePath: "https://picsum.photos/300/300",
        score: 4.5,
        isFavorited: false,
        recipeId: "27",
        recipeType: RecipeType.dinner,
        description: "Colorful roasted vegetables with herbs",
        cookingTime: 35,
        amountOfPeople: 4,
        difficulty: Difficulty.easy,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Beef Wellington",
        imagePath: "https://picsum.photos/300/300",
        score: 4.9,
        isFavorited: true,
        recipeId: "28",
        recipeType: RecipeType.dinner,
        description: "Elegant beef Wellington with puff pastry",
        cookingTime: 120,
        amountOfPeople: 4,
        difficulty: Difficulty.difficult,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Clam Chowder",
        imagePath: "https://picsum.photos/300/300",
        score: 4.0,
        isFavorited: false,
        recipeId: "29",
        recipeType: RecipeType.dinner,
        description: "Creamy clam chowder with potatoes and bacon",
        cookingTime: 45,
        amountOfPeople: 4,
        difficulty: Difficulty.intermediate,
        createdAt: DateTime.now(),
      ),
      Recipe(
        recipeName: "Mushroom Risotto",
        imagePath: "https://picsum.photos/300/300",
        score: 4.5,
        isFavorited: true,
        recipeId: "30",
        recipeType: RecipeType.dinner,
        description: "Creamy mushroom risotto with Parmesan",
        cookingTime: 35,
        amountOfPeople: 4,
        difficulty: Difficulty.intermediate,
        createdAt: DateTime.now(),
      ),
    ]
    ;
  }
}
