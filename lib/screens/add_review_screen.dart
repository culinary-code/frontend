import 'package:flutter/material.dart';
import 'package:frontend/services/review_service.dart';

class AddReviewScreen extends StatefulWidget {
  final String recipeId;

  const AddReviewScreen({super.key, required this.recipeId});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  int _rating = 0;

  void _submitReview() {
    if (_rating == 0) {
      // TODO: Show an error message
      return;
    }
    ReviewService().submitReview(widget.recipeId, _rating, _descriptionController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double appBarFontSize = screenWidth > 375 ? 18 : 14;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Voeg uw review aan dit recept toe!',
          style: TextStyle(fontSize: appBarFontSize),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Beoordeling:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Beschrijving (optioneel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitReview,
                child: Text('Review indienen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
