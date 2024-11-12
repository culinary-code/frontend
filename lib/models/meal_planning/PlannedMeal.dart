import 'package:frontend/models/recipes/recipe.dart';

class PlannedMeal {
  final int AmountOfPeople;
  final Recipe recipe;
  final DateTime plannedDay;

  PlannedMeal({
    required this.AmountOfPeople,
    required this.recipe,
    required this.plannedDay});
}