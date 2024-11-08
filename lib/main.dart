import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:frontend/navigation_menu.dart';
import 'package:frontend/registrationScreen.dart';
import 'package:frontend/theme/theme_loader.dart';

void main() async {
   await dotenv.load(fileName: ".env");
   await Settings.init(cacheProvider: SharePreferenceCache());
   //runApp(const MyApp());

    runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => MyApp(),
  ));

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
        debugShowCheckedModeBanner: false,
        home: const Main());
  }
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavigationMenu();
  }
}