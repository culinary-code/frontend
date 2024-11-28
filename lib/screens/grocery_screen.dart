import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/ingredients/ingredient_quantity.dart';
import 'package:frontend/models/recipes/ingredients/item_quantity.dart';
import 'package:frontend/models/recipes/ingredients/measurement_type.dart';
import 'package:frontend/services/account_service.dart';

import '../Services/keycloak_service.dart';
import '../models/meal_planning/grocery_list_item.dart';
import '../services/grocery_list_service.dart';

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
  late List<ItemQuantity> groceryList = [];
  final GroceryListService groceryListService = GroceryListService();
  final KeycloakService keycloakService = KeycloakService();
  final AccountService accountService = AccountService();

  String? groceryListId;

  List<Map<String, dynamic>> ingredientData = [];

  @override
  void initState() {
    super.initState();
    _loadGroceryList();
  }

  Future<void> _loadGroceryList() async {
    var groceryId = await groceryListService.getGroceryListId();
    var response =
        await groceryListService.fetchGroceryListById(groceryId.toString());
    groceryListId = await groceryListService.getGroceryListId();

    if (response != null) {
      var ingredients = response['ingredients'];
      var items = response['items'];

      List<Map<String, dynamic>> parsedData =
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
        // Convert MeasurementType to string for display (localized string)
        String measurementString = measurementTypeToStringNl(measurementType);

        return {
          'ingredientQuantityId': ingredient['ingredientQuantityId'],
          'ingredientName': ingredient['ingredient']['ingredientName'],
          'quantity': ingredient['quantity'],
          'measurement': measurementString,
        };
      }).toList();

      List<Map<String, dynamic>> parsedDataItems =
          items.map<Map<String, dynamic>>((ingredient) {
        var measurement = ingredient['ingredient']['measurement'];

        MeasurementType measurementType;
        if (measurement is int) {
          measurementType = intToMeasurementType(measurement);
        } else {
          measurementType = MeasurementType.kilogram;
        }
        String measurementString = measurementTypeToStringNl(measurementType);

        return {
          'ingredientQuantityId': ingredient['ingredientQuantityId'],
          'ingredientName': ingredient['ingredient']['ingredientName'],
          'quantity': ingredient['quantity'],
          'measurement': measurementString,
        };
      }).toList();

      setState(() {
        ingredientData = parsedData;
        ingredientData.addAll(parsedDataItems);
      });
    }
  }

  void addItem(ItemQuantity newItem) async {
    String? groceryListId = await groceryListService.getGroceryListId();
    if (groceryListId == null) {
      return;
    }

    bool itemExists = combinedData.any((item) =>
        item['ingredientName'].toString().toLowerCase() == newItem.groceryListItem.ingredientName.toLowerCase());

    if (itemExists) {
      final existingItem = combinedData.firstWhere((item) =>
          item['ingredientName'].toString().toLowerCase() == newItem.groceryListItem.ingredientName.toLowerCase());

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return DialogEditItem(
              initialQuantity: existingItem['quantity'],
              ingredientName: existingItem['ingredientName'],
              onQuantityUpdated: (updatedQuantity) {
                setState(
                  () {
                    // Update the quantity of the existing item
                    final updatedItem = ItemQuantity(
                      itemQuantityId: existingItem['ingredientQuantityId'],
                      quantity: updatedQuantity,
                      groceryListItem: newItem.groceryListItem,
                    );

                    // Update the existing item in the list
                    groceryListService.addItemToGroceryList(
                        groceryListId, updatedItem);
                    _loadGroceryList();
                  },
                );
              },
            );
          });
    }
    await groceryListService.addItemToGroceryList(groceryListId, newItem);
    await _loadGroceryList();
  }

  List<Map<String, dynamic>> get combinedData {
    List<Map<String, dynamic>> combinedList = [];

    combinedList.addAll(ingredientData);

    combinedList.addAll(groceryList.map((item) {
      return {
        'ingredientQuantityId': item.itemQuantityId,
        'ingredientName': item.groceryListItem.ingredientName,
        'quantity': item.quantity,
        'measurement':
            measurementTypeToStringNl(item.groceryListItem.measurement),
      };
    }).toList());
    return combinedList;
  }

  void deleteItem(String id) {
    groceryListService.deleteItemFromGroceryList(groceryListId!, id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            Table(
              border: TableBorder.all(color: Colors.black),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Boodschappenlijst',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 25),
                              ),
                            ),
                            Icon(Icons.shopping_cart, size: 30)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ...combinedData.map((ingredient) {
                  return TableRow(
                    children: [
                      Dismissible(
                        background: Container(
                          color: Colors.red,
                        ),
                        key: Key(ingredient['ingredientQuantityId']),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          final dismissedItem = ingredient;
                          setState(() {
                            ingredientData.removeWhere((item) =>
                                item['ingredientQuantityId'] ==
                                ingredient['ingredientQuantityId']);
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
                                      ingredientData.add(dismissedItem);
                                    });
                                  },
                                ),
                              ),
                            );
                            // Delay actual deletion to allow undo
                            Future.delayed(Duration(milliseconds: 3000), () {
                              if (isDeleting) {
                                // Perform deletion only if not undone
                                deleteItem(ingredient['ingredientQuantityId']);
                              }
                            });
                          });
                        },
                        child: GestureDetector(
                          onTap: () => showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return DialogEditItem(
                                    initialQuantity: ingredient['quantity'],
                                    ingredientName:
                                        ingredient['ingredientName'],
                                    onQuantityUpdated: (updatedQuantity) {
                                      setState(() {
                                        ingredient['quantity'] =
                                            updatedQuantity;
                                        final updatedItem = ItemQuantity(
                                          itemQuantityId: ingredient[
                                              'ingredientQuantityId'],
                                          quantity: updatedQuantity,
                                          groceryListItem: GroceryListItem(
                                            ingredientName:
                                                ingredient['ingredientName'],
                                            measurement:
                                                stringToMeasurementType(
                                                    ingredient['measurement']),
                                            ingredientQuantities: [],
                                          ),
                                        );
                                        addItem(updatedItem);
                                      });
                                    });
                              }),
                          child: Table(
                            children: [
                              TableRow(
                                children: [
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        ingredient['ingredientName'],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        "${ingredient['quantity'].toString()} ${ingredient['measurement']}",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Container(
                                      color: Colors.red,
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.keyboard_arrow_left,
                                                  color: Colors.black,
                                                  size: 30),
                                              Icon(Icons.delete,
                                                  color: Colors.black,
                                                  size: 30),
                                            ],
                                          )),
                                    )
                                    ,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
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
                              itemQuantityId: '',
                              quantity: quantity,
                              groceryListItem: GroceryListItem(
                                ingredientName: name,
                                measurement: measurement,
                                ingredientQuantities: [],
                              ),
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
        ),
      ),
    );
  }
}

class DialogEditItem extends StatefulWidget {
  final String ingredientName; // Add ingredientName parameter
  final double initialQuantity;
  final Function(double) onQuantityUpdated;

  const DialogEditItem(
      {super.key,
      required this.initialQuantity,
      required this.onQuantityUpdated,
      required this.ingredientName});

  @override
  State<DialogEditItem> createState() => _DialogEditItemState();
}

class _DialogEditItemState extends State<DialogEditItem> {
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController =
        TextEditingController(text: widget.initialQuantity.toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Bewerk de hoeveelheid van ${widget.ingredientName}'),
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
              widget.onQuantityUpdated(updatedQuantity);
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
