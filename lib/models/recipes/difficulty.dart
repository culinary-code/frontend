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

