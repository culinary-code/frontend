class Review {
  final String reviewId;
  final String? recipeId;
  final String reviewerUsername;
  final int amountOfStars;
  final String description;
  final DateTime createdAt;

  Review({
    required this.reviewId,
    this.recipeId,
    required this.reviewerUsername,
    required this.amountOfStars,
    required this.description,
    required this.createdAt,
  });
}