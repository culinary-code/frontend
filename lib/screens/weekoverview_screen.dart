import 'package:flutter/material.dart';
import 'package:frontend/models/meal_planning/PlannedMeal.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/screens/detail_screen.dart';
import 'package:http/http.dart' as http;

class WeekoverviewScreen extends StatelessWidget {
  const WeekoverviewScreen({super.key});

  static const List<String> daysOfWeek = [
    'Maandag',
    'Dinsdag',
    'Woensdag',
    'Donderdag',
    'Vrijdag',
    'Zaterdag',
    'Zondag'
  ];

  static getWeekDay(index) {
    var dateTime = DateTime.parse("2024-10-27");
    var addedDate = dateTime.add(Duration(days: index, hours: 3));
    var weekday = addedDate.weekday;
    var stringDay = daysOfWeek[weekday % 7];
    return stringDay;
  }

  static getRecipeForDay(weekdayInt) {
    var recipeList = Recipe.recipeList();
    return recipeList[(weekdayInt % recipeList.length)];
  }

  Future<void> openDatePicker(BuildContext context) async {
    // Show the date picker
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Initial date (default to today's date)
      firstDate: DateTime(2000), // Earliest date the user can pick
      lastDate: DateTime(2101), // Latest date the user can pick
    );

    // If a date is selected, display it in a snackbar or process it
    if (selectedDate != null) {
      // You can use the selectedDate variable for your purposes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected Date: ${selectedDate.toLocal()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Left button
          onPressed: () {
            // Handle left button press
          },
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Align to the left
          children: [
            Text(
              "Weekoverzicht",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "21/10/2024 - 27/10/2024",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ), // Center text
        centerTitle: false, // Center the title in the middle
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month), // First button on the right
            onPressed: () {
              // Handle first right button press
              openDatePicker(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward), // Second button on the right
            onPressed: () {
              // Handle second right button press
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16),
        itemCount: 7, // Number of custom elements to display
        itemBuilder: (context, index) {
          return PlannedMealWidget(
            // weekday: daysOfWeek[DateTime.parse("2024-10-27").add(Duration(days: index)).weekday - 1],
            weekday: getWeekDay(index),
            numberOfPeople: index.toString(),
            plannedMeal: PlannedMeal(
                AmountOfPeople: index + 1,
                recipe: getRecipeForDay(index),
                plannedDay: DateTime.parse("2024-10-27")
                    .add(Duration(days: index, hours: 3))),

            onButtonPressed: () => {},
          );
        },
      ),
    );
  }
}

class PlannedMealWidget extends StatelessWidget {
  final String weekday;
  final String numberOfPeople;
  final PlannedMeal plannedMeal;
  final VoidCallback onButtonPressed;

  const PlannedMealWidget({
    super.key,
    required this.weekday,
    required this.numberOfPeople,
    required this.plannedMeal,
    required this.onButtonPressed,
  });

  Future<bool> _checkImageUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      print('Error checking image URL: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          // Top Part
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Weekday String
                Text(
                  weekday,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Bottom Part
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 130,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailScreen(
                            recipeId: plannedMeal.recipe.recipeId)));
              },
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 130,
                    height: 130,
                    color: Colors.blueGrey,
                    child: FutureBuilder<bool>(
                      future: _checkImageUrl(plannedMeal.recipe.imagePath),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError || !snapshot.data!) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        } else {
                          return Image.network(
                            plannedMeal.recipe.imagePath,
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 10),
                  // Spacing between image and text/button column

                  // Column containing a string and a button
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          plannedMeal.recipe.recipeName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            _buildLabel(numberOfPeople, Icons.people),
                            const SizedBox(width: 8),
                            // Spacing between labels
                            _buildLabel("${plannedMeal.recipe.cookingTime}'",
                                Icons.access_time),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      // Add padding inside the border
      decoration: BoxDecoration(
        color: Colors.grey[200], // Background color of the label
        borderRadius: BorderRadius.circular(12), // Rounded corners
        border:
            Border.all(color: Colors.grey, width: 1), // Border color and width
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Shrink to fit the content
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4), // Small spacing between icon and text
          Icon(icon, size: 16),
        ],
      ),
    );
  }
}
