import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff8c4f27),
      surfaceTint: Color(0xff8c4f27),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdbc9),
      onPrimaryContainer: Color(0xff321200),
      secondary: Color(0xff765847),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdbc9),
      onSecondaryContainer: Color(0xff2b1609),
      tertiary: Color(0xff626033),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffe9e5ab),
      onTertiaryContainer: Color(0xff1e1d00),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff221a15),
      onSurfaceVariant: Color(0xff52443c),
      outline: Color(0xff85746b),
      outlineVariant: Color(0xffd7c2b8),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382e29),
      inversePrimary: Color(0xffffb68c),
      primaryFixed: Color(0xffffdbc9),
      onPrimaryFixed: Color(0xff321200),
      primaryFixedDim: Color(0xffffb68c),
      onPrimaryFixedVariant: Color(0xff6f3812),
      secondaryFixed: Color(0xffffdbc9),
      onSecondaryFixed: Color(0xff2b1609),
      secondaryFixedDim: Color(0xffe5bfaa),
      onSecondaryFixedVariant: Color(0xff5c4131),
      tertiaryFixed: Color(0xffe9e5ab),
      onTertiaryFixed: Color(0xff1e1d00),
      tertiaryFixedDim: Color(0xffccc992),
      onTertiaryFixedVariant: Color(0xff4a481d),
      surfaceDim: Color(0xffe7d7cf),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1eb),
      surfaceContainer: Color(0xfffceae2),
      surfaceContainerHigh: Color(0xfff6e5dd),
      surfaceContainerHighest: Color(0xfff0dfd7),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff6a340e),
      surfaceTint: Color(0xff8c4f27),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffa6643b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff573d2d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff8e6e5c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff46441a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff797747),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff8c0009),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffda342e),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff221a15),
      onSurfaceVariant: Color(0xff4e4038),
      outline: Color(0xff6c5c54),
      outlineVariant: Color(0xff88776e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382e29),
      inversePrimary: Color(0xffffb68c),
      primaryFixed: Color(0xffa6643b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff894c25),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff8e6e5c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff735645),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff797747),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff605e30),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffe7d7cf),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1eb),
      surfaceContainer: Color(0xfffceae2),
      surfaceContainerHigh: Color(0xfff6e5dd),
      surfaceContainerHighest: Color(0xfff0dfd7),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff3d1700),
      surfaceTint: Color(0xff8c4f27),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6a340e),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff331d10),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff573d2d),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff252300),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff46441a),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff4e0002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff8c0009),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff2d211b),
      outline: Color(0xff4e4038),
      outlineVariant: Color(0xff4e4038),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382e29),
      inversePrimary: Color(0xffffe7dc),
      primaryFixed: Color(0xff6a340e),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff4d2000),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff573d2d),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff3f2719),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff46441a),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff2f2e05),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffe7d7cf),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1eb),
      surfaceContainer: Color(0xfffceae2),
      surfaceContainerHigh: Color(0xfff6e5dd),
      surfaceContainerHighest: Color(0xfff0dfd7),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb68c),
      surfaceTint: Color(0xffffb68c),
      onPrimary: Color(0xff532200),
      primaryContainer: Color(0xff6f3812),
      onPrimaryContainer: Color(0xffffdbc9),
      secondary: Color(0xffe5bfaa),
      onSecondary: Color(0xff432b1c),
      secondaryContainer: Color(0xff5c4131),
      onSecondaryContainer: Color(0xffffdbc9),
      tertiary: Color(0xffccc992),
      onTertiary: Color(0xff333209),
      tertiaryContainer: Color(0xff4a481d),
      onTertiaryContainer: Color(0xffe9e5ab),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff1a120d),
      onSurface: Color(0xfff0dfd7),
      onSurfaceVariant: Color(0xffd7c2b8),
      outline: Color(0xff9f8d84),
      outlineVariant: Color(0xff52443c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff0dfd7),
      inversePrimary: Color(0xff8c4f27),
      primaryFixed: Color(0xffffdbc9),
      onPrimaryFixed: Color(0xff321200),
      primaryFixedDim: Color(0xffffb68c),
      onPrimaryFixedVariant: Color(0xff6f3812),
      secondaryFixed: Color(0xffffdbc9),
      onSecondaryFixed: Color(0xff2b1609),
      secondaryFixedDim: Color(0xffe5bfaa),
      onSecondaryFixedVariant: Color(0xff5c4131),
      tertiaryFixed: Color(0xffe9e5ab),
      onTertiaryFixed: Color(0xff1e1d00),
      tertiaryFixedDim: Color(0xffccc992),
      onTertiaryFixedVariant: Color(0xff4a481d),
      surfaceDim: Color(0xff1a120d),
      surfaceBright: Color(0xff413732),
      surfaceContainerLowest: Color(0xff140d08),
      surfaceContainerLow: Color(0xff221a15),
      surfaceContainer: Color(0xff271e19),
      surfaceContainerHigh: Color(0xff312823),
      surfaceContainerHighest: Color(0xff3d332d),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffbc96),
      surfaceTint: Color(0xffffb68c),
      onPrimary: Color(0xff2a0e00),
      primaryContainer: Color(0xffc77f54),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffeac3ae),
      onSecondary: Color(0xff251105),
      secondaryContainer: Color(0xffac8977),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffd1cd95),
      onTertiary: Color(0xff181700),
      tertiaryContainer: Color(0xff959360),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffbab1),
      onError: Color(0xff370001),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff1a120d),
      onSurface: Color(0xfffffaf8),
      onSurfaceVariant: Color(0xffdbc7bc),
      outline: Color(0xffb29f96),
      outlineVariant: Color(0xff918077),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff0dfd7),
      inversePrimary: Color(0xff703913),
      primaryFixed: Color(0xffffdbc9),
      onPrimaryFixed: Color(0xff220a00),
      primaryFixedDim: Color(0xffffb68c),
      onPrimaryFixedVariant: Color(0xff5a2803),
      secondaryFixed: Color(0xffffdbc9),
      onSecondaryFixed: Color(0xff1f0c03),
      secondaryFixedDim: Color(0xffe5bfaa),
      onSecondaryFixedVariant: Color(0xff493022),
      tertiaryFixed: Color(0xffe9e5ab),
      onTertiaryFixed: Color(0xff131200),
      tertiaryFixedDim: Color(0xffccc992),
      onTertiaryFixedVariant: Color(0xff39380e),
      surfaceDim: Color(0xff1a120d),
      surfaceBright: Color(0xff413732),
      surfaceContainerLowest: Color(0xff140d08),
      surfaceContainerLow: Color(0xff221a15),
      surfaceContainer: Color(0xff271e19),
      surfaceContainerHigh: Color(0xff312823),
      surfaceContainerHighest: Color(0xff3d332d),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffffaf8),
      surfaceTint: Color(0xffffb68c),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffbc96),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffffaf8),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffeac3ae),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfffffbea),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffd1cd95),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab1),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff1a120d),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfffffaf8),
      outline: Color(0xffdbc7bc),
      outlineVariant: Color(0xffdbc7bc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff0dfd7),
      inversePrimary: Color(0xff491d00),
      primaryFixed: Color(0xffffe1d2),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffbc96),
      onPrimaryFixedVariant: Color(0xff2a0e00),
      secondaryFixed: Color(0xffffe1d2),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffeac3ae),
      onSecondaryFixedVariant: Color(0xff251105),
      tertiaryFixed: Color(0xffede9b0),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffd1cd95),
      onTertiaryFixedVariant: Color(0xff181700),
      surfaceDim: Color(0xff1a120d),
      surfaceBright: Color(0xff413732),
      surfaceContainerLowest: Color(0xff140d08),
      surfaceContainerLow: Color(0xff221a15),
      surfaceContainer: Color(0xff271e19),
      surfaceContainerHigh: Color(0xff312823),
      surfaceContainerHighest: Color(0xff3d332d),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
