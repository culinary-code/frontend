class Recipe {
  final String recipeName;
  final double score;
  bool isFavorited;

  Recipe(
      {required this.recipeName,
      required this.score,
      this.isFavorited = false});

  static List<Recipe> recipeList() {
    return [
      Recipe(recipeName: "Puree met spinazie", score: 5.0),
      Recipe(recipeName: "Friet met stoofvlees", score: 4.6, isFavorited: true),
      Recipe(recipeName: "Aardappelgratin met bechamelsaus", score: 4.1),
      Recipe(recipeName: "Garnaalkroketten", score: 0.0, isFavorited: true)
    ];
  }
}
