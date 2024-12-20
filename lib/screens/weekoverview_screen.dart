import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/meal_planning/planned_meal.dart';
import 'package:frontend/screens/detail_screen.dart';
import 'package:frontend/services/planned_meals_service.dart';
import 'package:intl/intl.dart';

class WeekoverviewScreen extends StatelessWidget {
  const WeekoverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wat eten we deze week?", style: TextStyle(fontWeight: FontWeight.bold))),
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
  late Future<List<PlannedMealReduced>> _plannedMealsFuture;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _plannedMealsFuture =
        PlannedMealsService().getPlannedMealsByDate(context, _selectedDate);
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

  getDateSubtitleString() {
    return "${DateFormat('dd/MM/yyyy').format(_selectedDate)} - "
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
        _plannedMealsFuture =
            PlannedMealsService().getPlannedMealsByDate(context, _selectedDate);
      });
    }
  }

  updateSelectedDate(daysExtra) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: daysExtra));
      _plannedMealsFuture =
          PlannedMealsService().getPlannedMealsByDate(context, _selectedDate);
    });
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
        body: FutureBuilder<List<PlannedMealReduced>>(
          future: _plannedMealsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No planned meals found'));
            } else {
              final plannedMeals = snapshot.data!;

              // Generate the 7 days from _selectedDate
              List<DateTime> weekDates = List.generate(
                7,
                (index) => _selectedDate.add(Duration(days: index)),
              );

              return ListView.builder(
                itemCount: 7,
                itemBuilder: (context, index) {
                  DateTime currentDate = weekDates[index];

                  PlannedMealReduced? mealForDate;
                  try {
                    mealForDate = plannedMeals.firstWhere(
                      (meal) => isSameDate(meal.plannedDay, currentDate),
                    );
                  } catch (e) {
                    mealForDate = null;
                  }

                  if (mealForDate != null) {
                    return PlannedMealWidget(
                      weekday: getWeekDay(currentDate),
                      plannedMeal: mealForDate,
                      onButtonPressed: () => {},
                    );
                  } else {
                    // Show "No meal selected" if there's no meal for the date
                    return EmptyPlannedMealWidget(
                      weekday: getWeekDay(currentDate),
                    );
                  }
                },
              );
            }
          },
        ));
  }
}

class EmptyPlannedMealWidget extends StatelessWidget {
  final String weekday;

  const EmptyPlannedMealWidget({
    super.key,
    required this.weekday,
  });

  @override
  Widget build(BuildContext context) {
    // padding around the whole widget
    return Padding(
        padding: const EdgeInsets.fromLTRB(15, 8, 15, 16),
        child: Column(children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "Geen geselecteerde maaltijd.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          ])
        ]));
  }
}

class PlannedMealWidget extends StatelessWidget {
  final String weekday;
  final PlannedMealReduced plannedMeal;
  final VoidCallback onButtonPressed;

  const PlannedMealWidget({
    super.key,
    required this.weekday,
    required this.plannedMeal,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    // padding around the whole widget
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
                            recipeId: plannedMeal.recipe.recipeId, amountOfPeople: plannedMeal.amountOfPeople,)));
              },
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 130,
                    height: 130,
                    color: Colors.blueGrey,
                    child: plannedMeal.recipe.imagePath.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: plannedMeal.recipe.imagePath,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
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
                            _buildLabel(
                                context,
                                plannedMeal.amountOfPeople.toString(),
                                Icons.people),
                            const SizedBox(width: 8),
                            // Spacing between labels
                            _buildLabel(
                                context,
                                "${plannedMeal.recipe.cookingTime}'",
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
        border: Border.all(
            color: colorScheme.primary, width: 1), // Primary color border
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: textTheme.bodySmall?.copyWith(
              color:
                  colorScheme.onSurface, // Use theme's onSurface for text color
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
