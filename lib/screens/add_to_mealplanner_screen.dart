import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/ingredients/ingredient_quantity.dart';
import 'package:frontend/models/recipes/ingredients/measurement_type.dart';
import 'package:frontend/models/recipes/recipe.dart';

class AddToMealplannerScreen extends StatelessWidget {
  final Recipe recipe;

  const AddToMealplannerScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voeg het recept toe!")),
      body: AddToMealPlanner(
        recipe: recipe,
      ),
    );
  }
}

class AddToMealPlanner extends StatefulWidget {
  final Recipe recipe;

  const AddToMealPlanner({super.key, required this.recipe});

  @override
  State<AddToMealPlanner> createState() => _AddToMealPlanner();
}

class _AddToMealPlanner extends State<AddToMealPlanner> {
  bool isDeleting = false;
  bool isUndoPressed = false;
  late List<IngredientQuantity> ingredients;
  int numberOfPeople = 2;
  int initialPeopleCount = 2;
  late Map<String, double> originalQuantities;

  void _incrementPeople() {
    setState(() {
      numberOfPeople++;
      _updateIngredientQuantities();
    });
  }

  void _decrementPeople() {
    if (numberOfPeople > 1) {
      setState(() {
        numberOfPeople--;
        _updateIngredientQuantities();
      });
    }
  }

  void _updateIngredientQuantities() {
    double scaleFactor = numberOfPeople / initialPeopleCount;
    for (var ingredient in ingredients) {
      // Use the id to look up the original quantity in the map
      double originalQuantity = originalQuantities[ingredient.ingredientQuantityId] ?? 0;
      ingredient.quantity = originalQuantity * scaleFactor;
    }
  }

  void addItem(IngredientQuantity newIngredient) {
    setState(() {
      ingredients.add(newIngredient);
    });
  }

  void deleteItem(IngredientQuantity ingredient) {
    setState(() {
      ingredients.remove(ingredient);
      isDeleting = true;
    });
  }

  void _addToMealPlanner() {
    // Handle adding the recipe to the meal planner (logic here)
    print('Added to Meal Planner');
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    ingredients = recipe.ingredients;

    originalQuantities = {
      for (var ingredient in widget.recipe.ingredients) ingredient.ingredientQuantityId: ingredient.quantity
    };

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Title
            Text(
              recipe.recipeName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Recipe Image
            Center(
              child: Image.network(
                recipe.imagePath,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Number of People Section
            Row(
              children: [
                const Text('Number of People:'),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _decrementPeople,
                ),
                Text('$numberOfPeople'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _incrementPeople,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ingredients List Section
            const Text(
              'Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'You can remove ingredients you already have.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // List of Ingredients with swipe to remove
            Table(
              border: TableBorder.all(color: Colors.blueGrey.shade200),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                ...recipe.ingredients.map((ingredient) {
                  final ingredientName = ingredient.ingredient.ingredientName;
                  final quantity =
                      '${ingredient.quantity} ${(ingredient.quantity > 1) ? measurementTypeToStringMultipleNl(ingredient.ingredient.measurement) : measurementTypeToStringNl(ingredient.ingredient.measurement)}';

                  return TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Dismissible(
                            background: Container(
                              color: Colors.red,
                            ),
                            key: Key(ingredient.ingredientQuantityId),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              deleteItem(ingredient);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('$ingredientName is verwijderd'),
                                action: SnackBarAction(
                                    label: "Ongedaan maken",
                                    onPressed: () {
                                      isUndoPressed = true;
                                      setState(() {
                                        isDeleting = false;
                                        ingredients.add(ingredient);
                                      });
                                    }),
                              ));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    ingredientName,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(8, 0, 16, 0),
                                  child: Text(
                                    quantity,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                Container(
                                  color: Colors.red,
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.keyboard_arrow_left,
                                        size: 30,
                                      ),
                                      Icon(
                                        Icons.delete,
                                        color: Colors.black,
                                        size: 30,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                })
              ],
            ),

            const SizedBox(height: 20),

            // Add to Meal Planner Button
            Center(
              child: ElevatedButton(
                onPressed: _addToMealPlanner,
                child: const Text('Add to Meal Planner'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
