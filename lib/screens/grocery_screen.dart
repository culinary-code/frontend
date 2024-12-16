import 'package:flutter/material.dart';
import 'package:frontend/models/meal_planning/grocery_list_item.dart';
import 'package:frontend/models/recipes/ingredients/item_quantity.dart';
import 'package:frontend/models/recipes/ingredients/measurement_type.dart';
import 'package:frontend/services/grocery_list_service.dart';
import 'package:frontend/state/grocery_list_provider.dart';
import 'package:provider/provider.dart';

class GroceryScreen extends StatelessWidget {
  const GroceryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Laten we winkelen!")),
      body: const GroceryHeader(),
    );
  }
}

class GroceryHeader extends StatelessWidget {
  const GroceryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: GroceryList());
  }
}

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  bool isDeleting = false;
  bool isUndoPressed = false;
  bool isEditDialogOpen = false;
  final GroceryListService groceryListService = GroceryListService();

  List<Map<String, dynamic>> ingredientData = [];
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    final groceryListProvider =
    Provider.of<GroceryListProvider>(context, listen: false);
    groceryListProvider.getGroceryListFromDatabase(context);
  }

  void addItem(ItemQuantity newItem) async {
    final groceryListProvider =
    Provider.of<GroceryListProvider>(context, listen: false);
    final existingItem = groceryListProvider.ingredientData.firstWhere(
          (item) =>
      item['ingredientName'].toString().toLowerCase() ==
          newItem.groceryListItem.ingredientName.toLowerCase() &&
          item['recipeName'] == "Extra" &&
          item['measurement'] == newItem.groceryListItem.measurement,
      orElse: () => {},
    );

    if (existingItem.isNotEmpty) {
      final existingItem = groceryListProvider.ingredientData.firstWhere(
              (item) =>
          item['ingredientName'].toString().toLowerCase() ==
              newItem.groceryListItem.ingredientName.toLowerCase() &&
              item['recipeName'] == "Extra" &&
              item['measurement'] == newItem.groceryListItem.measurement);

      // if the dialog is not open for editing an already existing item, open it
      if (!isEditDialogOpen) {
        Future.delayed(Duration(milliseconds: 10), () {
          if (!mounted) return;
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return DialogEditItem(
                  initialQuantity: existingItem['quantity'],
                  ingredientName: existingItem['ingredientName'],
                  measurementType: existingItem['measurement'],
                  onQuantityUpdated: (updatedQuantity) async {
                    final updatedItem = ItemQuantity(
                        itemQuantityId: existingItem['ingredientQuantityId'],
                        quantity: updatedQuantity,
                        groceryListItem: newItem.groceryListItem,
                        isIngredient: existingItem['isIngredient']);

                    await groceryListService.addItemToGroceryList(context, updatedItem);
                    await groceryListProvider.getGroceryListFromDatabase(context);
                  },
                );
              });
        });
        // if the dialog was already open, make the call
      } else {
        await groceryListService.addItemToGroceryList(context, ItemQuantity(
            itemQuantityId: existingItem['ingredientQuantityId'],
            quantity: newItem.quantity,
            groceryListItem: newItem.groceryListItem,
            isIngredient: existingItem['isIngredient']));
        await groceryListProvider.getGroceryListFromDatabase(context);
      }
      // if the item was not found, call the function to add it
    } else {
      await groceryListService.addItemToGroceryList(context, newItem);
      await groceryListProvider.getGroceryListFromDatabase(context);
    }
  }

  Future<void> deleteItem(ItemQuantity item) async {
    await groceryListService.deleteItemFromGroceryList(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final groceryListProvider =
    Provider.of<GroceryListProvider>(context, listen: true);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart,
                size: 28, // Adjust size for prominence
              ),
              SizedBox(width: 12), // Adjust spacing between icon and text
              Text(
                "Boodschappenlijst",
                style: TextStyle(
                  fontSize: 24, // Larger font size for a header
                  fontWeight: FontWeight.bold, // Bold for emphasis
                  color: Colors.black, // A neutral color for text
                  letterSpacing: 1.2, // Slightly increased spacing for clarity
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: groceryListProvider.data.length,
            itemBuilder: (context, index) {
              final ingredient = groceryListProvider.data[index];
              return Dismissible(
                key: ValueKey(ingredient),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  final dismissedIngredient = ingredient;
                  setState(() {
                    groceryListProvider.data.removeWhere((loopIngredient) =>
                    loopIngredient['ingredientName'] ==
                        ingredient['ingredientName'] &&
                        loopIngredient['measurement'] ==
                            ingredient['measurement']);
                    isDeleting = true;
                  });

                  // Show Snackbar for undo option
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                      Text('${ingredient['ingredientName']} is verwijderd'),
                      action: SnackBarAction(
                        label: "Ongedaan maken",
                        onPressed: () {
                          setState(() {
                            isDeleting = false;
                            groceryListProvider.data.add(dismissedIngredient);
                          });
                        },
                      ),
                    ),
                  );

                  // Delay deletion to allow undo
                  Future.delayed(Duration(milliseconds: 3000), () async {
                    if (isDeleting) {
                      for (var detail in dismissedIngredient['details']) {
                        await deleteItem(
                          ItemQuantity(
                            itemQuantityId: detail['ingredientQuantityId'],
                            quantity: detail['quantity'],
                            groceryListItem: GroceryListItem(
                              ingredientName:
                              dismissedIngredient['ingredientName'],
                              measurement: dismissedIngredient['measurement'],
                              ingredientQuantities: [],
                            ),
                            isIngredient: detail['isIngredient'],
                          ),
                        );
                      }
                      await groceryListProvider.getGroceryListFromDatabase(context);
                    }
                  });
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.keyboard_arrow_left,
                          color: Colors.white, size: 30),
                      Icon(Icons.delete, color: Colors.white, size: 30),
                    ],
                  ),
                ),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          ingredient['ingredientName'],
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        ingredient['totalQuantity'].toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Text(
                        (ingredient['totalQuantity'] > 1)
                            ? measurementTypeToStringMultipleNl(
                            ingredient['measurement'])
                            : measurementTypeToStringNl(
                            ingredient['measurement']),
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  children: ingredient['details']
                      .map<Widget>((detail) => GestureDetector(
                      onTap: () {
                        if (!isEditDialogOpen) {
                          setState(() {
                            isEditDialogOpen = true;
                          });
                          Future.delayed(Duration(milliseconds: 10), () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DialogEditItem(
                                      initialQuantity: detail['quantity'],
                                      ingredientName:
                                      ingredient['ingredientName'],
                                      measurementType:
                                      ingredient['measurement'],
                                      onQuantityUpdated:
                                          (updatedQuantity) async {
                                        setState(() {
                                          detail['quantity'] =
                                              updatedQuantity;
                                          final updatedItem = ItemQuantity(
                                              itemQuantityId: detail[
                                              'ingredientQuantityId'],
                                              quantity: updatedQuantity,
                                              groceryListItem:
                                              GroceryListItem(
                                                ingredientName: ingredient[
                                                'ingredientName'],
                                                measurement: ingredient[
                                                'measurement'],
                                                ingredientQuantities: [],
                                              ),
                                              isIngredient:
                                              detail['isIngredient']);
                                          addItem(updatedItem);
                                        });
                                        await groceryListProvider
                                            .getGroceryListFromDatabase(context);
                                      });
                                }).then((_) {
                              Future.delayed(Duration(milliseconds: 100),
                                      () {
                                    setState(() {
                                      isEditDialogOpen = false;
                                    });
                                  });
                            });
                          });
                        }
                      },
                      child: Dismissible(
                        key: ValueKey(detail),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          final dismissedIngredientData = groceryListProvider.getIngredientData(detail['ingredientQuantityId']);
                          setState(() {
                            groceryListProvider.ingredientData.removeWhere((dismissedDetail) =>
                              dismissedDetail['ingredientQuantityId'] ==
                                          detail['ingredientQuantityId']
                            );
                            groceryListProvider.compileIngredientData();

                            isDeleting = true;
                          });

                          // Delay when deleting item
                          Future.delayed(Duration(milliseconds: 200), () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${ingredient['ingredientName']} is verwijderd'),
                                action: SnackBarAction(
                                  label: "Ongedaan maken",
                                  onPressed: () {
                                    setState(() {
                                      isDeleting = false;
                                      groceryListProvider.addIngredientData(dismissedIngredientData);
                                    });
                                  },
                                ),
                              ),
                            );
                            // Delay actual deletion to allow undo
                            Future.delayed(Duration(milliseconds: 3000),
                                    () async {
                                  if (isDeleting) {
                                    // Perform deletion only if not undone
                                    await deleteItem(ItemQuantity(
                                        itemQuantityId:
                                        detail['ingredientQuantityId'],
                                        quantity: detail['quantity'],
                                        groceryListItem: GroceryListItem(
                                            ingredientName:
                                            ingredient['ingredientName'],
                                            measurement:
                                            ingredient['measurement'],
                                            ingredientQuantities: []),
                                        isIngredient: detail['isIngredient']));
                                  }
                                  await groceryListProvider
                                      .getGroceryListFromDatabase(context);
                                });
                          });
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.keyboard_arrow_left,
                                  color: Colors.white, size: 30),
                              Icon(Icons.delete,
                                  color: Colors.white, size: 30),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  detail['recipeName'],
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Text(
                                detail['quantity'].toString(),
                                textAlign: TextAlign.right,
                                style:
                                TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 10),
                              Text(
                                (detail['quantity'] > 1)
                                    ? measurementTypeToStringMultipleNl(
                                    ingredient['measurement'])
                                    : measurementTypeToStringNl(
                                    ingredient['measurement']),
                                textAlign: TextAlign.right,
                                style: TextStyle(color: Colors.grey),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.keyboard_arrow_left,
                                      color: Colors.red, size: 30),
                                  Icon(Icons.delete,
                                      color: Colors.red, size: 30),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )))
                      .toList(),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return DialogInputGrocery(
                          onAdd: (name, quantity, measurement) {
                            final newItem = ItemQuantity(
                              itemQuantityId:
                              '00000000-0000-0000-0000-000000000000',
                              quantity: quantity,
                              groceryListItem: GroceryListItem(
                                ingredientName: name,
                                measurement: measurement,
                                ingredientQuantities: [],
                              ),
                              isIngredient: false,
                            );
                            addItem(newItem);
                          });
                    },
                  );
                },
                icon: const Icon(Icons.add_box, size: 50),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class DialogEditItem extends StatefulWidget {
  final String ingredientName;
  final double initialQuantity;
  final MeasurementType measurementType;
  final Function(double) onQuantityUpdated;

  const DialogEditItem(
      {super.key,
        required this.initialQuantity,
        required this.onQuantityUpdated,
        required this.ingredientName,
        required this.measurementType});

  @override
  State<DialogEditItem> createState() => _DialogEditItemState();
}

class _DialogEditItemState extends State<DialogEditItem> {
  late TextEditingController _quantityController;
  late Function(double) onQuantityUpdated;

  @override
  void initState() {
    super.initState();
    _quantityController =
        TextEditingController(text: widget.initialQuantity.toString());
    onQuantityUpdated = widget.onQuantityUpdated;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Text('Wijzig ${widget.ingredientName}'),
          Text(
            '${widget.ingredientName} bedraagt momenteel ${widget.initialQuantity} ${measurementTypeToStringNl(widget.measurementType)}, hoeveel wil je er van maken?',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      content: TextField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: "Voer hoeveelheid in"),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Annuleren'),
        ),
        TextButton(
          onPressed: () {
            final updatedQuantity = double.tryParse(_quantityController.text);
            if (updatedQuantity != null && updatedQuantity > 0) {
              onQuantityUpdated(updatedQuantity);
              Navigator.pop(context);
            }
          },
          child: const Text('Opslaan'),
        ),
      ],
    );
  }
}

class DialogInputGrocery extends StatefulWidget {
  final Function(String, double, MeasurementType) onAdd;

  const DialogInputGrocery({super.key, required this.onAdd});

  @override
  State<DialogInputGrocery> createState() => _DialogInputGroceryState();
}

class _DialogInputGroceryState extends State<DialogInputGrocery> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  MeasurementType selectedMeasurement = MeasurementType.kilogram;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Wat wil je toevoegen?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Naam"),
          ),
          TextField(
            controller: quantityController,
            decoration: const InputDecoration(hintText: '1'),
            keyboardType: TextInputType.number,
          ),
          DropdownButton<MeasurementType>(
            value: selectedMeasurement,
            onChanged: (MeasurementType? newValue) {
              setState(() {
                selectedMeasurement = newValue!;
              });
            },
            items: MeasurementType.values.map((MeasurementType measurement) {
              return DropdownMenuItem<MeasurementType>(
                value: measurement,
                child: Text(measurementTypeToStringNl(measurement)),
              );
            }).toList(),
          )
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuleer')),
        TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final quantity =
                  double.tryParse(quantityController.text.trim()) ?? 1.0;

              if (name.isNotEmpty && quantity > 0) {
                widget.onAdd(name, quantity, selectedMeasurement);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Voeg toe'))
      ],
    );
  }
}
