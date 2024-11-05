import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Laten we koken!")),
        body: const RecipeHeader());
  }
}

class RecipeHeader extends StatefulWidget {
  const RecipeHeader({super.key});

  @override
  State<RecipeHeader> createState() => _RecipeHeaderState();
}

class _RecipeHeaderState extends State<RecipeHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Friet met stoofvlees",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Image.asset('images/default_image.png')
        ],
      ),
    );
  }
}

/*class MealOverview extends StatefulWidget {
  const MealOverview({super.key});

  @override
  State<MealOverview> createState() => _MealOverviewState();
}

class _MealOverviewState extends State<MealOverview> {
  //final List<Ingredient> _ingredients =


}*/
