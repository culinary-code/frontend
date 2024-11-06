import 'package:flutter/material.dart';
import 'package:frontend/screens/weekoverview_screen.dart';

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
  late final List<String> _ingredients = [
    "2:grote aardappelen",
    "500g:vlees",
    "1:ui",
    "1 tl:zout",
    "1 tl:peper",
    "2 el:olijfolie",
    "220 ml:druivensap"
  ];
  late final List<Instruction> _instructionSteps =
      Instruction.instructionList();

  bool isFavorited = false;

  void toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecipeHeader(
                isFavorited: isFavorited, onFavoriteToggle: toggleFavorite),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                  color: Colors.blueGrey[200],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 8,
                        offset: const Offset(0, 5))
                  ]),
              child: const RecipeDetailsGrid(),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                  'Stoofvlees is een gerecht van langzaam gegaard rundvlees in een rijke saus op basis van bier of bouillon. '
                  'Het vlees wordt boterzacht en vol van smaak, ideaal comfortfood voor koude dagen.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 18)),
            ),
            const PortionSelector(),
            const SizedBox(height: 16.0),
            IngredientsOverview(ingredientList: _ingredients),
            const SizedBox(height: 16.0),
            InstructionsOverview(instructionsSteps: _instructionSteps),
            const SizedBox(height: 16.0),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 45.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WeekoverviewScreen()));
                },
                child: const Text('+ Weekoverzicht'),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    ));
  }
}

class RecipeHeader extends StatefulWidget {
  final bool isFavorited;
  final VoidCallback onFavoriteToggle;

  const RecipeHeader(
      {super.key, required this.isFavorited, required this.onFavoriteToggle});

  @override
  State<RecipeHeader> createState() => _RecipeHeaderState();
}

class _RecipeHeaderState extends State<RecipeHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'images/default.jpg',
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                  child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Friet met stoofvlees",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
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
        ],
      ),
    );
  }
}

class RecipeDetailsGrid extends StatelessWidget {
  const RecipeDetailsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GridItem(icon: Icons.timer, label: '30 min'),
          GridItem(icon: Icons.dinner_dining, label: 'Avondeten'),
          GridItem(icon: Icons.thermostat, label: 'Gemiddeld')
        ],
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const GridItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueGrey[800], size: 30),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class PortionSelector extends StatefulWidget {
  const PortionSelector({super.key});

  @override
  State<PortionSelector> createState() => _PortionSelectorState();
}

class _PortionSelectorState extends State<PortionSelector> {
  int portions = 2;

  void addPortions() {
    setState(() {
      portions++;
    });
  }

  void removePortions() {
    setState(() {
      if (portions > 1) portions--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_dining,
                    size: 30,
                    color: Colors.blueGrey[800],
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Porties',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800]),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: removePortions,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.blueGrey[200],
                      child: Icon(
                        Icons.remove,
                        color: Colors.blueGrey[800],
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$portions',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: addPortions,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.blueGrey[200],
                      child: Icon(
                        Icons.add,
                        color: Colors.blueGrey[800],
                        size: 18,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

class IngredientsOverview extends StatelessWidget {
  final List<String> ingredientList;

  const IngredientsOverview({super.key, required this.ingredientList});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
            border: TableBorder.all(color: Colors.white24),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[200],
                  ),
                  children: const [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Ingrediênt',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Hoeveelheid',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                    ),
                  ]),
              ...ingredientList.map((ingredient) {
                final split = ingredient.split(":");
                final ingredientName = split[0];
                final quantity = split.length > 1 ? split[1] : '';

                return TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              quantity,
                              style: const TextStyle(fontSize: 18),
                            ),
                          )),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            ingredientName,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              })
            ],
          ),
        ));
  }
}

class InstructionsOverview extends StatelessWidget {
  final List<Instruction> instructionsSteps;

  const InstructionsOverview({super.key, required this.instructionsSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bereidingswijze",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...instructionsSteps.asMap().entries.map((entry) {
            int index = entry.key;
            Instruction step = entry.value;
            return Text(
              "${index + 1}. ${step.step}",
              style: const TextStyle(fontSize: 18),
            );
          }),
        ],
      ),
    );
  }
}
