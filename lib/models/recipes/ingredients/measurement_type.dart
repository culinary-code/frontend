enum MeasurementType {
  kilogram,
  litre,
  pound,
  ounce,
  teaspoon,
  tablespoon,
  piece,
  millilitre,
  gram,
  pinch,
  toTaste
}

MeasurementType intToMeasurementType(int value) {
  switch (value) {
    case 0:
      return MeasurementType.kilogram;
    case 1:
      return MeasurementType.litre;
    case 2:
      return MeasurementType.pound;
    case 3:
      return MeasurementType.ounce;
    case 4:
      return MeasurementType.teaspoon;
    case 5:
      return MeasurementType.tablespoon;
    case 6:
      return MeasurementType.piece;
    case 7:
      return MeasurementType.millilitre;
    case 8:
      return MeasurementType.gram;
    case 9:
      return MeasurementType.pinch;
    case 10:
      return MeasurementType.toTaste;
    default:
      throw ArgumentError('Invalid integer value for MeasurementType');
  }
}