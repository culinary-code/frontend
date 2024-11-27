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
  toTaste,
  clove
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
    case 11:
      return MeasurementType.clove;
    default:
      throw ArgumentError('Invalid integer value for MeasurementType');
  }
}

String measurementTypeToStringNl(MeasurementType type) {
  switch (type) {
    case MeasurementType.kilogram:
      return 'kg';
    case MeasurementType.litre:
      return 'l';
    case MeasurementType.pound:
      return 'pond';
    case MeasurementType.ounce:
      return 'ounce';
    case MeasurementType.teaspoon:
      return 'tl';
    case MeasurementType.tablespoon:
      return 'el';
    case MeasurementType.piece:
      return 'stuk';
    case MeasurementType.millilitre:
      return 'ml';
    case MeasurementType.gram:
      return 'g';
    case MeasurementType.pinch:
      return 'snufje';
    case MeasurementType.toTaste:
      return 'naar smaak';
    case MeasurementType.clove:
      return 'teentje';
  }
}

String measurementTypeToStringMultipleNl(MeasurementType type) {
  switch (type) {
    case MeasurementType.piece:
      return 'stukken';
    case MeasurementType.clove:
      return 'teentjes';
    case MeasurementType.pinch:
      return 'snufjes';
    default:
      return measurementTypeToStringNl(type);
  }
}

MeasurementType stringToMeasurementType(String value) {
  switch (value) {
    case 'kg':
      return MeasurementType.kilogram;
    case 'l':
      return MeasurementType.litre;
    case 'pond':
      return MeasurementType.pound;
    case 'ounce':
      return MeasurementType.ounce;
    case 'tl':
      return MeasurementType.teaspoon;
    case 'el':
      return MeasurementType.tablespoon;
    case 'stuk':
      return MeasurementType.piece;
    case 'ml':
      return MeasurementType.millilitre;
    case 'g':
      return MeasurementType.gram;
    case 'snufje':
      return MeasurementType.pinch;
    case 'naar smaak':
      return MeasurementType.toTaste;
    case 'teentje':
      return MeasurementType.clove;
    default:
      throw ArgumentError('Invalid string value for MeasurementType');
  }
}
