import 'package:frontend/models/accounts/account.dart';
import 'package:frontend/models/recipes/recipe.dart';

class Preference {
  final String preferenceId;
  final String preferenceName;
  final bool standardPreference;
  final List<Recipe> recipes;
  final List<Account> accounts;

  Preference({
    required this.preferenceId,
    required this.preferenceName,
    required this.standardPreference,
    required this.recipes,
    this.accounts = const [],
  });

  factory Preference.fromJson(Map<String, dynamic> json) {
    return Preference(
      preferenceName: json['preferenceName'] as String,
      standardPreference: json['standardPreference'] as bool, preferenceId: json['preferenceId'], recipes: [],
    );
  }

  // Convert Preference to JSON
  Map<String, dynamic> toJson() {
    return {
      "preferenceId": preferenceId,
      "preferenceName": preferenceName,
      "standardPreference": standardPreference,
    };
  }
}