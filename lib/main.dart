import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/state/RecipeFilterOptionsProvider.dart';
import 'package:frontend/theme/theme_loader.dart';
import 'package:frontend/screens/keycloak/login_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await Settings.init(cacheProvider: SharePreferenceCache());
  // runApp(const MyApp());

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => RecipeFilterOptionsProvider()),
        ],
        child:
      DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => MyApp(),
  )));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness brightness = MediaQuery.of(context).platformBrightness;

    ThemeData theme = ThemeLoader.loadTheme(brightness);

    return MaterialApp(
        title: 'Culinary Code',
        theme: theme,
        locale: Locale('nl'),

        // These delegates make sure that Material widgets use the correct localization
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'), // English
          const Locale('nl'), // Dutch
          // Add more supported locales here
        ],
        debugShowCheckedModeBanner: false,
        home: const Main());
  }
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginPage();
    // return const NavigationMenu();
  }
}
