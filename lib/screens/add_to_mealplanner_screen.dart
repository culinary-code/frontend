import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/ingredients/ingredient_quantity.dart';
import 'package:frontend/models/recipes/ingredients/measurement_type.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/navigation_menu.dart';

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
  late int numberOfPeople;
  late int initialPeopleCount;
  late Map<String, double> originalQuantities;
  late Recipe recipe;

  void _incrementPeople() {
    setState(() {
      numberOfPeople++;
      _updateIngredientQuantities();
      ingredients;
    });
  }

  void _decrementPeople() {
    if (numberOfPeople > 1) {
      setState(() {
        numberOfPeople--;
        _updateIngredientQuantities();
        ingredients;
      });
    }
  }

  void _updateIngredientQuantities() {
    double scaleFactor = numberOfPeople / initialPeopleCount;
    for (var ingredient in ingredients) {
      // Use the id to look up the original quantity in the map
      double originalQuantity =
          originalQuantities[ingredient.ingredientQuantityId] ?? 0;
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

  void _addToMealPlanner() async {
    final DateTime today = DateTime.now();
    final DateTime lastDate = today.add(const Duration(days: 6));

    // Show the date picker
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: lastDate,
    );

    // Optional: handle the selected date
    if (selectedDate != null) {
      //TODO: when implementing the backend method for saving a meal to the mealplanner: add call to backend here

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const NavigationMenu(initialIndex: 1),
        ),
        (route) => false, // This removes all previous routes
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize ingredients and originalQuantities only once
    recipe = widget.recipe;

    ingredients = recipe.ingredients.map((ingredient) {
      // Create a new IngredientQuantity object by copying the properties
      return IngredientQuantity(
        ingredientQuantityId: ingredient.ingredientQuantityId,
        ingredient: ingredient.ingredient,
        quantity: ingredient.quantity, // Copy the quantity
      );
    }).toList();

    // Store the original quantities for scaling purposes
    originalQuantities = {
      for (var ingredient in ingredients)
        ingredient.ingredientQuantityId: ingredient.quantity
    };

    numberOfPeople = recipe.amountOfPeople;
    initialPeopleCount = recipe.amountOfPeople;
  }

  @override
  Widget build(BuildContext context) {
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
                width: double.infinity,
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
                ...ingredients.map((ingredient) {
                  final ingredientName = ingredient.ingredient.ingredientName;
                  final quantity =
                      '${ingredient.quantity == ingredient.quantity.toInt() ? '${ingredient.quantity.toInt()}' // Display as integer if it's a whole number
                          : ingredient.quantity.toStringAsFixed(2)} ${(ingredient.quantity > 1) ? measurementTypeToStringMultipleNl(ingredient.ingredient.measurement) : measurementTypeToStringNl(ingredient.ingredient.measurement)}';

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
