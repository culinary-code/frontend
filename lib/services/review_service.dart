import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:frontend/ErrorNotifier.dart';
import 'package:frontend/models/accounts/review.dart';
import 'package:frontend/services/api_client.dart';
import 'package:provider/provider.dart';

class ReviewService {

  Future<List<Review>> getReviewsByRecipeId(BuildContext context, String recipeId) async {
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet(context, 'Review/ByRecipeId/$recipeId');
    if (response == null) return [];
    if (response.statusCode != 200) {
      Provider.of<ErrorNotifier>(context, listen: false).showError(
          "Er is iets misgegaan bij het ophalen van uw recensies. Probeer het later opnieuw.");
      return [];
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

  Future<Map<bool, String>> submitReview(BuildContext context, String recipeId, int rating, String description) async {
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedPost(context, 'Review/CreateReview', {
      'recipeId': recipeId,
      'amountOfStars': rating,
      'description': description,
    });
    if (response == null) return {false: ""};

    if (response.statusCode == 409) {
      Provider.of<ErrorNotifier>(context, listen: false).showError(
          "Je hebt dit recept al beoordeeld!");
      return {false: 'U heeft dit recept al beoordeeld!'};
    }

    if (response.statusCode != 200) {
      Provider.of<ErrorNotifier>(context, listen: false).showError(
          "Er is iets misgegaan bij het toevoegen van uw review. Probeer het later opnieuw.");
      return {false: 'Er is iets misgegaan bij het toevoegen van uw review. Probeer het later opnieuw.'};
    }

    return {true: 'Review succesvol toegevoegd!'};
  }
}