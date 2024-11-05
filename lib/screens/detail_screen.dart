import 'package:flutter/material.dart';
import 'package:frontend/screens/weekoverview_screen.dart';
import 'package:input_quantity/input_quantity.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecipeHeader(
                isFavorited: isFavorited, onFavoriteToggle: toggleFavorite),
            const SizedBox(height: 16),
            const InformationOverview(),
            const SizedBox(height: 16),
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

/*
class IngredientsOverview extends StatelessWidget {
  final List<String> ingredientList;

  const IngredientsOverview({super.key, required this.ingredientList});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ingrediënten",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          //...ingredientList.map((ingredient) => Text(ingredient))
          ...ingredientList.asMap().entries.map((entry) {
            String ingredient = entry.value;
            return Text(
              "• $ingredient",
              style: const TextStyle(fontSize: 16),
            );
          })
        ],
      ),
    );
  }
}*/

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
            border: TableBorder.all(color: Colors.black),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                  ),
                  children: [
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

class InformationOverview extends StatefulWidget {
  const InformationOverview({super.key});

  @override
  State<InformationOverview> createState() => _InformationOverviewState();
}

class _InformationOverviewState extends State<InformationOverview> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(Icons.person),
          Text("Serves"),
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: InputQty(
                initVal: 0, // aanpassen naar ingesteld aantal personen
                minVal: 0,
                maxVal: 100,
                steps: 1,
                qtyFormProps: QtyFormProps(enableTyping: true),
                decoration: QtyDecorationProps(
                  isBordered: true,
                  contentPadding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  isDense: true,
                  width: 10,
                  minusBtn: Icon(Icons.remove, color: Colors.blue),
                  plusBtn: Icon(Icons.add, color: Colors.blue),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
