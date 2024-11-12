import 'package:flutter/material.dart';

class WeekoverviewScreen extends StatelessWidget {
  const WeekoverviewScreen({super.key});

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
          return CustomElement(
            title: 'Item ${index + 1}',
            subtitle: 'This is the subtitle for item ${index + 1}',
          );
        },
      ),
    );
  }
}

class CustomElement extends StatelessWidget {
  final String title;
  final String subtitle;

  CustomElement({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
