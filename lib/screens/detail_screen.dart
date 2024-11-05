import 'package:flutter/material.dart';

import '../models/ingredient.dart';
import '../models/instruction.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Laten we koken!")),
      body: const DetailOverview(),
    );
  }
}

class DetailOverview extends StatefulWidget {
  const DetailOverview({super.key});

  @override
  State<DetailOverview> createState() => _DetailOverviewState();
}

class _DetailOverviewState extends State<DetailOverview> {
  late final List<Ingredient> _ingredients;
  late final List<Instruction> _instructionSteps = Instruction.instructionList();

  bool isFavorited = false;

  void toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecipeHeader(isFavorited: isFavorited, onFavoriteToggle: toggleFavorite),
            const IngredientsOverview(),
            Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: (1),
                    itemBuilder: (BuildContext context, int index) {
                      return InstructionsOverview(
                          instructionsSteps: _instructionSteps);
                    }))
          ],
        ));
  }
}

class RecipeHeader extends StatefulWidget {
  final bool isFavorited;
  final VoidCallback onFavoriteToggle;

  const RecipeHeader({
    super.key,
    required this.isFavorited,
    required this.onFavoriteToggle});

  @override
  State<RecipeHeader> createState() => _RecipeHeaderState();
}

class _RecipeHeaderState extends State<RecipeHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Friet met stoofvlees",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 1),
              GestureDetector(
                  onTap: widget.onFavoriteToggle,
                  child: Icon(
                      widget.isFavorited ? Icons.favorite : Icons.favorite_border,
                      size: 30,
                      color: widget.isFavorited ? Colors.red : Colors.blueGrey),
              ),
            ],
          ),
          Image.asset('images/default_image.png'),
        ],
      ),
    );
  }
}

class IngredientsOverview extends StatelessWidget {
  const IngredientsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ingrediënten",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}

class InstructionsOverview extends StatelessWidget {
  final List<Instruction> instructionsSteps;

  const InstructionsOverview({super.key, required this.instructionsSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bereidingswijze",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...instructionsSteps
              .asMap()
              .entries
              .map((entry) {
            int index = entry.key;
            Instruction step = entry.value;
            return Text("${index + 1}. ${step.step}");
          }),
        ],
      ),
    );
  }
}