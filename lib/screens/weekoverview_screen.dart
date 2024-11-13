import 'package:flutter/material.dart';
import 'package:frontend/models/meal_planning/PlannedMeal.dart';
import 'package:frontend/screens/detail_screen.dart';
import 'package:frontend/services/planned_meals_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeekoverviewScreen extends StatelessWidget {
  const WeekoverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wat eten we deze week?")),
      body: WeekOverview(),
    );
  }
}

class WeekOverview extends StatefulWidget {
  const WeekOverview({super.key});

  @override
  State<WeekOverview> createState() => _WeekOverviewState();
}

class _WeekOverviewState extends State<WeekOverview> {

  late Future<List<PlannedMeal>> _plannedMealsFuture;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _plannedMealsFuture = PlannedMealsService().getDummyPlannedMeals(_selectedDate);
  }

  static const List<String> daysOfWeek = [
    'Maandag',
    'Dinsdag',
    'Woensdag',
    'Donderdag',
    'Vrijdag',
    'Zaterdag',
    'Zondag'
  ];

  static getWeekDay(dateTime) {
    var weekday = dateTime.weekday - 1;
    var stringDay = daysOfWeek[weekday % 7];
    return stringDay;
  }

  getDateSubtitleString(){
    return
        "${DateFormat('dd/MM/yyyy').format(_selectedDate)} - "
        "${DateFormat('dd/MM/yyyy').format(_selectedDate.add(Duration(days: 6)))}";
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
      setState(() {
        _selectedDate = selectedDate;
        _plannedMealsFuture = PlannedMealsService().getDummyPlannedMeals(_selectedDate);
      });
    }
  }

  updateSelectedDate(daysExtra){
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: daysExtra));
      _plannedMealsFuture = PlannedMealsService().getDummyPlannedMeals(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Left button
          onPressed: () {
            // Handle left button press
            updateSelectedDate(-7);
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
              getDateSubtitleString(),
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ), // Center text
        centerTitle: true, // Center the title in the middle
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
              updateSelectedDate(7);
            },
          ),
        ],
      ),

      body: FutureBuilder<List<PlannedMeal>>(
        future: _plannedMealsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No planned meals found'));
          } else {
            final plannedMeals = snapshot.data!;
            return ListView.builder(
              itemCount: plannedMeals.length,
              itemBuilder: (context, index) {
                return PlannedMealWidget(
                  weekday: getWeekDay(plannedMeals[index].plannedDay),
                  plannedMeal: plannedMeals[index],
                  onButtonPressed: () => {},
                );
              },
            );
          }
        },
      ),
    );
  }
}



class PlannedMealWidget extends StatelessWidget {
  final String weekday;
  final PlannedMeal plannedMeal;
  final VoidCallback onButtonPressed;

  const PlannedMealWidget({
    super.key,
    required this.weekday,
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
                            _buildLabel(context, plannedMeal.amountOfPeople.toString(), Icons.people),
                            const SizedBox(width: 8),
                            // Spacing between labels
                            _buildLabel(context, "${plannedMeal.recipe.cookingTime}'",
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

  Widget _buildLabel(BuildContext context, String text, IconData icon) {
    // Access the current theme's color scheme
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1), // Lightened primary color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary, width: 1), // Primary color border
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface, // Use theme's onSurface for text color
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            icon,
            size: 16,
            color: colorScheme.primary, // Use primary color for the icon
          ),
        ],
      ),
    );
  }
}
