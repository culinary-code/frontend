enum Difficulty {
  notAvailable,
  easy,
  intermediate,
  difficult
}

Difficulty intToDifficulty(int difficulty) {
  switch (difficulty) {
    case 0:
      return Difficulty.notAvailable;
    case 1:
      return Difficulty.easy;
    case 2:
      return Difficulty.intermediate;
    case 3:
      return Difficulty.difficult;
    default:
      return Difficulty.notAvailable;
  }
}

String difficultyToStringNl(Difficulty difficulty) {
  switch (difficulty) {
    case Difficulty.notAvailable:
      return 'Niet beschikbaar';
    case Difficulty.easy:
      return 'Makkelijk';
    case Difficulty.intermediate:
      return 'Gemiddeld';
    case Difficulty.difficult:
      return 'Moeilijk';
    default:
      return 'Niet beschikbaar';
  }
}

String recipeDifficultyToStringNlFromIntString(String integerValueString) {
  return difficultyToStringNl(intToDifficulty(int.parse(integerValueString)));
}
