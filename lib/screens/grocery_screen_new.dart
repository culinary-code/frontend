import 'package:flutter/material.dart';
import 'package:frontend/models/meal_planning/grocery_list_item.dart';
import 'package:frontend/models/recipes/ingredients/item_quantity.dart';
import 'package:frontend/models/recipes/ingredients/measurement_type.dart';
import 'package:frontend/services/grocery_list_service.dart';

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
    _loadGroceryList();
  }

  Future<void> _loadGroceryList() async {
    var response = await groceryListService.fetchGroceryListByAccountId();

    if (response != null) {
      var ingredients = response['ingredients'];
      var items = response['items'];

      List<Map<String, dynamic>> parsedIngredientData =
          ingredients.map<Map<String, dynamic>>((ingredient) {
        var measurement = ingredient['ingredient']['measurement'];

        // Convert measurement integer to MeasurementType enum
        MeasurementType measurementType;
        if (measurement is int) {
          // Map the integer value to the corresponding MeasurementType
          measurementType = intToMeasurementType(measurement);
        } else {
          measurementType = MeasurementType.kilogram;
        }
        return {
          'ingredientQuantityId': ingredient['ingredientQuantityId'],
          'ingredientName': ingredient['ingredient']['ingredientName'],
          'quantity': ingredient['quantity'],
          'measurement': measurementType,
          'recipeName': ingredient['recipeName']?.isEmpty ?? true
              ? "Extra"
              : ingredient['recipeName'],
          'isIngredient': true
        };
      }).toList();

      List<Map<String, dynamic>> parsedDataItems =
          items.map<Map<String, dynamic>>((item) {
        var measurement = item['groceryItem']['measurement'];

        MeasurementType measurementType;
        if (measurement is int) {
          measurementType = intToMeasurementType(measurement);
        } else {
          measurementType = MeasurementType.kilogram;
        }
        return {
          'ingredientQuantityId': item['itemQuantityId'],
          'ingredientName': item['groceryItem']['groceryItemName'],
          'quantity': item['quantity'],
          'measurement': measurementType,
          'recipeName': "Extra",
          'isIngredient': false
        };
      }).toList();

      // combine both lists
      setState(() {
        ingredientData = parsedIngredientData;
        ingredientData.addAll(parsedDataItems);
      });

      compileIngredientData();
    }
  }

  void compileIngredientData() {
    // Step 1: Group by ingredientName and measurement
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var ingredient in ingredientData) {
      String key =
          '${ingredient['ingredientName']}_${ingredient['measurement'].index.toString()}'; // Unique key for grouping
      grouped.putIfAbsent(key, () => []).add(ingredient);
    }

    // Step 2: Calculate total quantities and format the output
    List<Map<String, dynamic>> transformed = grouped.entries.map((entry) {
      String key = entry.key;
      List<Map<String, dynamic>> items = entry.value;

      // Split the key back into ingredientName and measurement
      List<String> splitKey = key.split('_');
      String ingredientName = splitKey[0];
      String measurement = splitKey[1];
      MeasurementType measurementType =
          intToMeasurementType(int.parse(measurement));
      num totalQuantity = items.fold(0, (sum, item) => sum + item['quantity']);

      // Sort the details: "Extra" should always be last
      List<Map<String, dynamic>> sortedDetails = items.map((item) {
        return {
          'ingredientQuantityId': item['ingredientQuantityId'],
          'recipeName': item['recipeName'],
          'quantity': item['quantity'],
          'isIngredient': item['isIngredient']
        };
      }).toList()
        ..sort((a, b) {
          if (a['recipeName'] == "Extra" && b['recipeName'] != "Extra") {
            return 1; // "Extra" goes after other items
          } else if (a['recipeName'] != "Extra" && b['recipeName'] == "Extra") {
            return -1; // Other items go before "Extra"
          } else {
            return 0; // Keep the relative order otherwise
          }
        });

      return {
        'ingredientName': ingredientName,
        'measurement': measurementType,
        'totalQuantity': totalQuantity,
        'details': sortedDetails,
      };
    }).toList();

    // Step 3: Sort ingredients alphabetically by ingredientName
    transformed
        .sort((a, b) => a['ingredientName'].compareTo(b['ingredientName']));

    // Output result
    setState(() {
      data = transformed;
    });
  }

  void addItem(ItemQuantity newItem) async {
    final existingItem = ingredientData.firstWhere(
      (item) =>
          item['ingredientName'].toString().toLowerCase() ==
              newItem.groceryListItem.ingredientName.toLowerCase() &&
          item['recipeName'] == "Extra",
      orElse: () => {},
    );

    if (existingItem.isNotEmpty) {
      final existingItem = ingredientData.firstWhere((item) =>
          item['ingredientName'].toString().toLowerCase() ==
              newItem.groceryListItem.ingredientName.toLowerCase() &&
          item['recipeName'] == "Extra");

      // if the dialog is not open for editing an already existing item, open it
      if (!isEditDialogOpen) {
        Future.delayed(Duration(milliseconds: 10), () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return DialogEditItem(
                  initialQuantity: existingItem['quantity'],
                  ingredientName: existingItem['ingredientName'],
                  measurementType: existingItem['measurement'],
                  onQuantityUpdated: (updatedQuantity) {
                    setState(() {
                      final updatedItem = ItemQuantity(
                          itemQuantityId: existingItem['ingredientQuantityId'],
                          quantity: updatedQuantity,
                          groceryListItem: newItem.groceryListItem,
                          isIngredient: existingItem['isIngredient']);

                      groceryListService.addItemToGroceryList(updatedItem);
                      _loadGroceryList();
                    });
                  },
                );
              });
        });
        // if the dialog was already open, make the call
      } else {
        await groceryListService.addItemToGroceryList(ItemQuantity(
            itemQuantityId: existingItem['ingredientQuantityId'],
            quantity: newItem.quantity,
            groceryListItem: newItem.groceryListItem,
            isIngredient: existingItem['isIngredient']));
        await _loadGroceryList();
      }
      // if the item was not found, call the function to add it
    } else {
      await groceryListService.addItemToGroceryList(newItem);
      await _loadGroceryList();
    }
  }

  void deleteItem(ItemQuantity item) {
    groceryListService.deleteItemFromGroceryList(item);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final ingredient = data[index];
              return Dismissible(
                key: ValueKey(ingredient['ingredientName']),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  final dismissedIngredient = ingredient;
                  setState(() {
                    data.removeWhere(
                      (loopIngredient) =>
                          loopIngredient['ingredientName'] ==
                          ingredient['ingredientName'],
                    );
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
                            data.add(dismissedIngredient);
                          });
                        },
                      ),
                    ),
                  );

                  // Delay deletion to allow undo
                  Future.delayed(Duration(milliseconds: 3000), () {
                    if (isDeleting) {
                      for (var detail in dismissedIngredient['details']) {
                        deleteItem(
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
                        measurementTypeToStringNl(ingredient['measurement']),
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
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return DialogEditItem(
                                        initialQuantity: detail['quantity'],
                                        ingredientName:
                                            ingredient['ingredientName'],
                                        measurementType:
                                            ingredient['measurement'],
                                        onQuantityUpdated: (updatedQuantity) {
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
                                                  measurement:
                                                      ingredient['measurement'],
                                                  ingredientQuantities: [],
                                                ),
                                                isIngredient:
                                                    detail['isIngredient']);
                                            addItem(updatedItem);
                                          });
                                        });
                                  }).then((_) {
                                Future.delayed(Duration(milliseconds: 100), () {
                                  setState(() {
                                    isEditDialogOpen = false;
                                  });
                                });
                              });
                            }
                          },
                          child: Dismissible(
                            key: ValueKey(detail),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              final dismissedDetail = detail;
                              final dismissedIngredient = ingredient;
                              setState(() {
                                for (var loopIngredient in data) {
                                  if (loopIngredient['ingredientName'] ==
                                      ingredient['ingredientName']) {
                                    loopIngredient['details'].removeWhere(
                                        (dismissedDetail) =>
                                            dismissedDetail[
                                                'ingredientQuantityId'] ==
                                            detail['ingredientQuantityId']);
                                  }
                                }

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
                                          dismissedIngredient['details']
                                              .add(dismissedDetail);
                                        });
                                      },
                                    ),
                                  ),
                                );
                                // Delay actual deletion to allow undo
                                Future.delayed(Duration(milliseconds: 3000),
                                    () {
                                  if (isDeleting) {
                                    // Perform deletion only if not undone
                                    deleteItem(ItemQuantity(
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
                                    measurementTypeToStringNl(
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
