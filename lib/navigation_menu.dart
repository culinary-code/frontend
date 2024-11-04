import 'package:flutter/material.dart';
import 'package:frontend/screens/account_screen.dart';
import 'package:frontend/screens/favorite_screen.dart';
import 'package:frontend/screens/grocery_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/mealplanner_screen.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _currentIndex = 0;

  var screens = [
    const HomeScreen(),
    const MealplannerScreen(),
    const GroceryScreen(),
    const FavoriteScreen(),
    const AccountScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: screens[_currentIndex],
      ),
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