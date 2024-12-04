import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/Services/keycloak_service.dart';
import 'package:frontend/navigation_menu.dart';
import 'package:frontend/state/api_selection_provider.dart';
import 'package:frontend/state/favorite_recipe_provider.dart';
import 'package:frontend/state/recipe_filter_options_provider.dart';
import 'package:frontend/theme/theme_loader.dart';
import 'package:frontend/screens/keycloak/login_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await Settings.init(cacheProvider: SharePreferenceCache());

  bool developmentMode;
  if (dotenv.env['DEVELOPMENT_MODE'] != null) {
    String? val = dotenv.env['DEVELOPMENT_MODE'];
    developmentMode = bool.parse(val!);
  } else {
    developmentMode = false;
  }

  if (developmentMode) {
    runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) => RecipeFilterOptionsProvider()),
          ChangeNotifierProvider(create: (context) => ApiSelectionProvider()),
          ChangeNotifierProvider(create: (context) => FavoriteRecipeProvider())
        ],
        child: DevicePreview(
          enabled: !kReleaseMode,
          builder: (context) => MyApp(),
        )));
  } else {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => RecipeFilterOptionsProvider()),
        ChangeNotifierProvider(create: (context) => ApiSelectionProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteRecipeProvider())
      ],
      child: MyApp(),
    ));
  }
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

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  bool _isLoggedIn = false;
  bool _isCheckingLoginStatus = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      await KeycloakService().getAccessToken();
      setState(() {
        _isLoggedIn = true;
      });
    } on FormatException catch (e) {
      setState(() {
        _isLoggedIn = false;
      });
    } finally {
      setState(() {
        _isCheckingLoginStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingLoginStatus) {
      return const SplashScreen();
    } else if (_isLoggedIn) {
      return const NavigationMenu();
    } else {
      return const LoginPage();
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/culinarycode_logo.png'),
          const SizedBox(height: 20),
          CircularProgressIndicator(),
          Text('Culinary Code',
              style: Theme.of(context).textTheme.headlineLarge),
        ],
      )),
    );
  }
}
