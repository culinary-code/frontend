class Recipe {
  final String recipeName;
  final double score;
  bool isFavorited;

  Recipe({
    required this.recipeName,
    required this.score,
    this.isFavorited = false
  });
}