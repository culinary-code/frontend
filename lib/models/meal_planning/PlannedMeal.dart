import 'package:frontend/models/recipes/recipe.dart';

class PlannedMeal {
  final int amountOfPeople;
  final Recipe recipe;
  final DateTime plannedDay;

  PlannedMeal({
    required this.amountOfPeople,
    required this.recipe,
    required this.plannedDay});
}