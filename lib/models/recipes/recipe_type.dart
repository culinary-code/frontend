enum RecipeType {
  notAvailable,
  breakfast,
  lunch,
  dinner,
  dessert,
  snack
}

RecipeType intToRecipeType(int value) {
  switch (value) {
    case 0:
      return RecipeType.notAvailable;
    case 1:
      return RecipeType.breakfast;
    case 2:
      return RecipeType.lunch;
    case 3:
      return RecipeType.dinner;
    case 4:
      return RecipeType.dessert;
    case 5:
      return RecipeType.snack;
    default:
      throw ArgumentError('Invalid integer value for RecipeType');
  }
}

String recipeTypeToStringNl(RecipeType type) {
  switch (type) {
    case RecipeType.notAvailable:
      return 'Not Available';
    case RecipeType.breakfast:
      return 'Ontbijt';
    case RecipeType.lunch:
      return 'Lunch';
    case RecipeType.dinner:
      return 'Avondeten';
    case RecipeType.dessert:
      return 'Dessert';
    case RecipeType.snack:
      return 'Snack';
    default:
      throw ArgumentError('Invalid RecipeType');
  }
}

// used for the filter options chips since they all hold a string value
// in this case of the index of the recipetype
String recipeTypeToStringNlFromIntString(String integerValueString) {
  return recipeTypeToStringNl(intToRecipeType(int.parse(integerValueString)));
}

