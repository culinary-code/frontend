import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/navigation_menu.dart';
import 'package:frontend/screens/keycloak/login_screen.dart';
import 'package:frontend/screens/keycloak/registration_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  // runApp(const MyApp());

  runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Culinary Code',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
          // Theme of Project
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const Main());
  }
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}
