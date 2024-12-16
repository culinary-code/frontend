import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/ErrorNotifier.dart';
import 'package:frontend/Services/keycloak_service.dart';
import 'package:frontend/navigation_menu.dart';
import 'package:frontend/screens/invitation_screen.dart';
import 'package:frontend/state/api_selection_provider.dart';
import 'package:frontend/state/favorite_recipe_provider.dart';
import 'package:frontend/state/grocery_list_provider.dart';
import 'package:frontend/state/recipe_filter_options_provider.dart';
import 'package:frontend/theme/theme_loader.dart';
import 'package:frontend/screens/keycloak/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          ChangeNotifierProvider(create: (context) => FavoriteRecipeProvider()),
          ChangeNotifierProvider(create: (context) => GroceryListProvider()),
          ChangeNotifierProvider(create: (context) => ErrorNotifier()),
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
        ChangeNotifierProvider(create: (context) => FavoriteRecipeProvider()),
        ChangeNotifierProvider(create: (context) => GroceryListProvider()),
        ChangeNotifierProvider(create: (context) => ErrorNotifier()),
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
  String? _pendingInvitationCode;

  late StreamSubscription _linkSubscription; // For listening to incoming links
  bool get _isDevelopmentMode =>
      dotenv.env['DEVELOPMENT_MODE']?.toLowerCase() == 'true';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    if (!_isDevelopmentMode) {
      _initDeepLinkListener();
    }
  }

  Future<void> _checkLoginStatus() async {
    var result = await KeycloakService().getAccessToken(context);
    if (result == null) {
      setState(() {
        _isLoggedIn = false;
      });
    } else {
      setState(() {
        _isLoggedIn = true;
      });
    }
    // with this method running, it will make it so the login screen shows immediately with a provided api url
    final apiSelectionProvider =
        Provider.of<ApiSelectionProvider>(context, listen: false);
    await apiSelectionProvider.backendUrl;

    setState(() {
      _isCheckingLoginStatus = false;
    });

    // Once login status is checked, initialize the deep link listener
    if (!_isCheckingLoginStatus && !_isDevelopmentMode) {
      _initDeepLinkListener();
    }
  }

  Future<void> _initDeepLinkListener() async {
    // Handle initial deep link
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _processDeepLink(Uri.parse(initialLink));
    }

    // Listen for subsequent deep links
    _linkSubscription = linkStream.listen((link) {
      if (link != null) {
        _processDeepLink(Uri.parse(link));
      }
    });
  }

  void _processDeepLink(Uri link) async {
    if (link.host == 'culinarycode.com' &&
        link.path.startsWith('/accept-invitation/')) {
      final invitationCode = link.queryParameters['invitation_code'] ??
          (link.pathSegments.isNotEmpty
              ? link.pathSegments.last
              : 'Uitnodiging is vervallen!');

      if (_isLoggedIn) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InvitationScreen(invitationCode: invitationCode),
          ),
        );
      } else {
        // Store the invitation code for later use after login
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('pending_invitation_code', invitationCode);

        setState(() {
          _pendingInvitationCode = invitationCode;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  void dispose() {
    if (!_isDevelopmentMode) {
      _linkSubscription
          .cancel(); // Unsubscribe from the link stream only if initialized
    } // Unsubscribe from the link stream
    super.dispose();
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
        body: Consumer<ErrorNotifier>(builder: (context, errorNotifier, child) {
      // Display error message if available
      if (errorNotifier.errorMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorNotifier.errorMessage!)),
          );
          errorNotifier.clearError(); // Clear the error after displaying
        });
      }

      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/culinarycode_logo.png'),
          const SizedBox(height: 20),
          CircularProgressIndicator(),
          Text('Culinary Code',
              style: Theme.of(context).textTheme.headlineLarge),
        ],
      ));
    }));
  }
}
