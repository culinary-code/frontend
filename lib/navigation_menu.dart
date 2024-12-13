import 'package:flutter/material.dart';
import 'package:frontend/ErrorNotifier.dart';
import 'package:frontend/screens/account_screen.dart';
import 'package:frontend/screens/favorite_screen.dart';
import 'package:frontend/screens/grocery_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/weekoverview_screen.dart';
import 'package:provider/provider.dart';

class NavigationMenu extends StatefulWidget {
  final int initialIndex;

  const NavigationMenu({super.key, this.initialIndex = 0});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  late int _currentIndex;

  var screens = [
    const HomeScreen(),
    const WeekoverviewScreen(),
    const GroceryScreen(),
    const FavoriteScreen(),
    const AccountScreen()
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget
        .initialIndex; // Set the starting index based on the passed parameter
  }

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

        return Container(
          child: screens[_currentIndex],
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant), label: "Maaltijdplanner"),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_grocery_store), label: "Boodschappen"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favorieten"),
          BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts), label: "Account")
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemSelected,
      ),
    );
  }

  void _onItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
