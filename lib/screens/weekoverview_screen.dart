import 'package:flutter/material.dart';
import 'package:frontend/models/meal_planning/PlannedMeal.dart';
import 'package:frontend/models/recipes/recipe.dart';

class WeekoverviewScreen extends StatelessWidget {
  const WeekoverviewScreen({super.key});

  static const List<String> daysOfWeek = [
    'Maandag', 'Dinsdag', 'Woensdag', 'Donderdag', 'Vrijdag', 'Zaterdag', 'Zondag'
  ];

  static getWeekDay(index){
    var dateTime =  DateTime.parse("2024-10-27");
    var addedDate = dateTime.add(Duration(days: index, hours: 3));
    var weekday = addedDate.weekday;
    var stringDay = daysOfWeek[weekday - 1];
    return stringDay;
  }

  static getRecipeForDay(weekdayInt){
    var recipeList = Recipe.recipeList();
    return recipeList[(weekdayInt % recipeList.length)];
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
          return CustomWidget(
            // weekday: daysOfWeek[DateTime.parse("2024-10-27").add(Duration(days: index)).weekday - 1],
            weekday: getWeekDay(index),
            numberOfPeople: index.toString(),
            plannedMeal: PlannedMeal(AmountOfPeople: index + 1, recipe: getRecipeForDay(index), plannedDay: DateTime.parse("2024-10-27").add(Duration(days: index, hours: 3))),

            onButtonPressed: () => {},

          );
        },
      ),
    );
  }
}

class CustomWidget extends StatelessWidget {
  final String weekday;
  final String numberOfPeople;
  final PlannedMeal plannedMeal;
  final VoidCallback onButtonPressed;

  const CustomWidget({
    super.key,
    required this.weekday,
    required this.numberOfPeople,
    required this.plannedMeal,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return
      Column(
      children: [
        // Top Part
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Weekday String
              Text(
                weekday,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Bottom Part
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 100),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image on the left
                Image.network(
                  plannedMeal.recipe.imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, size: 50),
                ),

                const SizedBox(width: 16),
                // Spacing between image and text/button column

                // Column containing a string and a button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text String
                      Text(
                        plannedMeal.recipe.recipeName,
                        style: TextStyle(fontSize: 16),
                      ),

                      const SizedBox(width: 8),

                      // Right-aligned labels with icons
                      Row(
                        children: [
                          _buildLabel(numberOfPeople, Icons.people),
                          const SizedBox(width: 8), // Spacing between labels
                          _buildLabel("${plannedMeal.recipe.cookingTime}'", Icons.access_time),
                        ],
                      ),

                      // Spacer to push the button to the bottom
                      Spacer(),

                      // Button
                      ElevatedButton(
                        onPressed: onButtonPressed,
                        child: Text("Open"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Add padding inside the border
      decoration: BoxDecoration(
        color: Colors.grey[200], // Background color of the label
        borderRadius: BorderRadius.circular(12), // Rounded corners
        border: Border.all(color: Colors.grey, width: 1), // Border color and width
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
