class RecipeSuggestion {
  final String recipeName;
  final String description;

  RecipeSuggestion({required this.recipeName, required this.description});

  static RecipeSuggestion fromJson(Map<String, dynamic> json) {
    return RecipeSuggestion(
      recipeName: json['recipeName'],
      description: json['description'],
    );
  }
}