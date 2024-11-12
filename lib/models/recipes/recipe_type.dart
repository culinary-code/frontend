enum RecipeType {
  breakfast,
  lunch,
  dinner,
  dessert,
  snack
}

RecipeType intToRecipeType(int value) {
  switch (value) {
    case 0:
      return RecipeType.breakfast;
    case 1:
      return RecipeType.lunch;
    case 2:
      return RecipeType.dinner;
    case 3:
      return RecipeType.dessert;
    case 4:
      return RecipeType.snack;
    default:
      throw ArgumentError('Invalid integer value for RecipeType');
  }
}