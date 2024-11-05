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
  late final List<Instruction> _instructionSteps;

  final List<String> _instructionSteps2 = [
    "Schil de aardappelen",
    "Snij de aardappelen in frietvorm"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RecipeHeader(),
        const IngredientsOverview(),
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: (1),
                itemBuilder: (BuildContext context, int index) {
                  return InstructionsOverview(
                      instructionsSteps: _instructionSteps2);
                }))
      ],
    ));
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
      padding: const EdgeInsets.symmetric(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Friet met stoofvlees",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
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
  final List<String> instructionsSteps;

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
          ...instructionsSteps.map((step) => Text(step)),
          //Text(instructionsSteps[1])
        ],
      ),
    );
  }
}
