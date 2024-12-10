import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/accounts/account.dart';
import 'package:frontend/models/meal_planning/planned_meal.dart';
import 'package:frontend/models/recipes/ingredients/ingredient_quantity.dart';
import 'package:frontend/models/recipes/ingredients/measurement_type.dart';
import 'package:frontend/models/recipes/recipe.dart';
import 'package:frontend/navigation_menu.dart';
import 'package:frontend/services/account_service.dart';
import 'package:frontend/services/planned_meals_service.dart';

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
  late List<AddMealPlannerIngredientQuantity> ingredients;
  late int numberOfPeople;
  late int initialPeopleCount;
  late Map<String, double> originalQuantities;
  late Recipe recipe;

  final AccountService _accountService = AccountService();
  late String userId;
  late Future<void> _initFuture;

  bool allIngredientsAdded = true;

  // Initialization for familySize
  Future<void> _initialize() async {
    try {
      userId = await _accountService.getUserId();
      Account user = await _accountService.fetchUser(userId);

      int userFamilySize =
          user.familySize > 0 ? user.familySize : recipe.amountOfPeople;

      double scaleFactor = userFamilySize / recipe.amountOfPeople;

      setState(() {
        numberOfPeople = userFamilySize;
        initialPeopleCount = recipe.amountOfPeople;

        for (var ingredient in ingredients) {
          String id = ingredient.ingredientQuantity.ingredientQuantityId;
          double originalQuantity =
              originalQuantities[id] ?? ingredient.ingredientQuantity.quantity;
          ingredient.ingredientQuantity.quantity =
              originalQuantity * scaleFactor;
        }
      });
    } catch (e) {
      // When no familySize is installed, use default recipe size
      setState(() {
        numberOfPeople = recipe.amountOfPeople;
        initialPeopleCount = recipe.amountOfPeople;
      });
    }
  }

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
      double originalQuantity = originalQuantities[
              ingredient.ingredientQuantity.ingredientQuantityId] ??
          0;
      ingredient.ingredientQuantity.quantity = originalQuantity * scaleFactor;
    }
  }

  void addItem(AddMealPlannerIngredientQuantity newIngredient) {
    setState(() {
      ingredients.add(newIngredient);
    });
  }

  void deleteItem(AddMealPlannerIngredientQuantity ingredient) {
    setState(() {
      ingredients.remove(ingredient);
      isDeleting = true;
    });
  }

  void toggleItemAddedToRecipe(AddMealPlannerIngredientQuantity ingredient) {
    setState(() {
      ingredient.isAddedToList = !ingredient.isAddedToList;
      allIngredientsAdded =
          ingredients.every((ingredient) => ingredient.isAddedToList);
    });
  }

  void toggleAllIngredients() {
    setState(() {
      // check if one ingredient is added to the list, if so, set all to true, if all ingredients are already added, set all to false
      if (ingredients.every((ingredient) => ingredient.isAddedToList)) {
        for (var ingredient in ingredients) {
          ingredient.isAddedToList = false;
        }
        allIngredientsAdded = false;
      } else if (ingredients.any((ingredient) => ingredient.isAddedToList)) {
        for (var ingredient in ingredients) {
          ingredient.isAddedToList = true;
        }
        allIngredientsAdded = true;
      } else {
        for (var ingredient in ingredients) {
          ingredient.isAddedToList = true;
        }
        allIngredientsAdded = true;
      }
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
      if (!mounted) return;

      PlannedMealFull plannedMeal = PlannedMealFull(
        amountOfPeople: numberOfPeople,
        recipe: recipe,
        plannedDay: selectedDate,
        ingredients: ingredients
            .where((item) =>
                item.isAddedToList) // Filter items with isAddedToList true
            .map((item) => item.ingredientQuantity) // Map filtered items
            .toList(),
      );

      await PlannedMealsService().createPlannedMeal(plannedMeal);

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
    _initFuture = _initialize();
    // Initialize ingredients and originalQuantities only once

    recipe = widget.recipe;

    ingredients = recipe.ingredients.map((ingredient) {
      // Create a new IngredientQuantity object by copying the properties
      return AddMealPlannerIngredientQuantity(
          ingredientQuantity: IngredientQuantity(
            ingredientQuantityId: ingredient.ingredientQuantityId,
            ingredient: ingredient.ingredient,
            quantity: ingredient.quantity, // Copy the quantity
          ),
          isAddedToList: true);
    }).toList();

    // Store the original quantities for scaling purposes
    originalQuantities = {
      for (var ingredient in recipe.ingredients)
        ingredient.ingredientQuantityId: ingredient.quantity
    };

    numberOfPeople = recipe.amountOfPeople;
    initialPeopleCount = recipe.amountOfPeople;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return _buildContent(context);
      },
    );
  }

  Widget _buildContent(BuildContext context) {
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
              child: recipe.imagePath.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: recipe.imagePath,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // Number of People Section
            Row(
              children: [
                const Text('Aantal personen:'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ingrediënten',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: toggleAllIngredients,
                  child: Text(
                    allIngredientsAdded
                        ? 'Deselecteer alles'
                        : 'Selecteer alles',
                  ),
                )
              ],
            ),

            const SizedBox(height: 5),
            const Text(
              'Je kan hier ingrediënten toevoegen & verwijderen aan je boodschappenlijst.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // List of Ingredients with swipe to remove
            Table(
              border: TableBorder.all(color: Colors.blueGrey.shade200),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                ...ingredients.map((ingredient) {
                  return buildIngredientRow(
                    context,
                    ingredient,
                    () => toggleItemAddedToRecipe(ingredient),
                  );
                })
              ],
            ),

            const SizedBox(height: 20),

            // Add to Meal Planner Button
            Center(
                child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addToMealPlanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const Text(
                        'Voeg toe aan maaltijdplanner',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class AddMealPlannerIngredientQuantity {
  final IngredientQuantity ingredientQuantity;
  bool isAddedToList = false;

  AddMealPlannerIngredientQuantity(
      {required this.ingredientQuantity, required this.isAddedToList});
}

// Swipeable table row that changes based on being added to the ingredientlist
TableRow buildIngredientRow(
    BuildContext context,
    AddMealPlannerIngredientQuantity ingredient,
    VoidCallback toggleItemAddedToRecipe) {
  final ingredientName =
      ingredient.ingredientQuantity.ingredient.ingredientName;
  final quantity =
      '${ingredient.ingredientQuantity.quantity == ingredient.ingredientQuantity.quantity.toInt() ? ingredient.ingredientQuantity.quantity.toInt() // Display as integer if it's a whole number
          : ingredient.ingredientQuantity.quantity.toStringAsFixed(2)} ${(ingredient.ingredientQuantity.quantity > 1) ? measurementTypeToStringMultipleNl(ingredient.ingredientQuantity.ingredient.measurement) : measurementTypeToStringNl(ingredient.ingredientQuantity.ingredient.measurement)}';

  return TableRow(
    children: [
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
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
                padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                child: Text(
                  quantity,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Transform.scale(
                scale: 1.5, // Adjust the scale factor as needed
                child: Checkbox(
                  value: ingredient.isAddedToList,
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.green[400];
                    }
                    return Colors.red[300];
                  }),
                  onChanged: (bool? value) {
                    toggleItemAddedToRecipe();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
