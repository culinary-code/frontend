import 'dart:convert';

import 'package:frontend/models/accounts/review.dart';
import 'package:frontend/services/api_client.dart';

class ReviewService {

  Future<List<Review>> getReviewsByRecipeId(String recipeId) async {
    final response = await ApiClient().authorizedGet('Review/ByRecipeId/$recipeId');

    if (response.statusCode != 200) {
      throw FormatException('Failed to load reviews: ${response.body}');
    }

    final List<dynamic> dynamicReviews = json.decode(response.body);

    final List<Review> reviews = dynamicReviews.map((dynamic review) {
      return Review(
        reviewId: review['reviewId'],
        recipeId: review['recipeId'],
        reviewerUsername: review['reviewerUsername'],
        amountOfStars: review['amountOfStars'],
        description: review['description'],
        createdAt: DateTime.parse(review['createdAt']),
      );
    }).toList();

    return reviews;
  }

  Future<Map<bool, String>> submitReview(String recipeId, int rating, String description) async {
    final response = await ApiClient().authorizedPost('Review/CreateReview', {
      'recipeId': recipeId,
      'amountOfStars': rating,
      'description': description,
    });

    if (response.statusCode == 409) {
      return {false: 'U heeft dit recept al beoordeeld!'};
    }

    if (response.statusCode != 200) {
      return {false: 'Er is iets misgegaan bij het toevoegen van uw review. Probeer het later opnieuw.'};
    }

    return {true: 'Review succesvol toegevoegd!'};
  }
}