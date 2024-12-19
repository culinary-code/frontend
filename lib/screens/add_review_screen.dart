import 'package:flutter/material.dart';
import 'package:frontend/services/review_service.dart';
import 'package:frontend/state/recipe_filter_options_provider.dart';
import 'package:provider/provider.dart';

class AddReviewScreen extends StatefulWidget {
  final String recipeId;

  const AddReviewScreen({super.key, required this.recipeId});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  int _rating = 0;
  bool _showRatingError = false;
  static const int _maxDescriptionLength = 650;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_updateCounter);
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_updateCounter);
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateCounter() {
    setState(() {
      _counter = _descriptionController.text.length;
    });
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      setState(() {
        _showRatingError = true;
      });
      return;
    }
    Map<bool, String> result = await ReviewService()
        .submitReview(context, widget.recipeId, _rating, _descriptionController.text);

    if (!mounted) return;

    if (result.keys.first) {
      // force refresh of recipes in the home screen to show the new recipe
      final filterProvider =
      Provider.of<RecipeFilterOptionsProvider>(context, listen: false);
      filterProvider.onFilterChanged(context);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double appBarFontSize = screenWidth > 375 ? 18 : 14;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Voeg review toe aan dit recept!',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                      _showRatingError = false;
                    });
                  },
                );
              }),
            ),
            if (_showRatingError)
              Text('Selecteer een beoordeling',
                  style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Beschrijving (optioneel)',
                border: OutlineInputBorder(),
                counterText: '$_counter/$_maxDescriptionLength',
              ),
              maxLength: _maxDescriptionLength,
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