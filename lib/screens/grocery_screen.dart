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
        child:
          GroceryList());
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

  String? groceryListId; // Store the grocery list ID here

  // New Ingredient data list for fetching ingredients from API
  List<Map<String, dynamic>> ingredientData = [];

  @override
  void initState() {
    super.initState();
    _loadGroceryList();
  }

  Future<void> _loadGroceryList() async {
    var groceryId = await groceryListService.getGroceryListId();
    var response = await groceryListService.fetchGroceryListById(groceryId.toString());
    groceryListId = await groceryListService.getGroceryListId(); // Fetch and store the grocery list ID

    if (response != null) {
      var ingredients = response['ingredients'];
      var items = response['items'];

      List<Map<String, dynamic>> parsedData = ingredients.map<Map<String, dynamic>>((ingredient) {
        var measurement = ingredient['ingredient']['measurement'];

        // Convert measurement integer to MeasurementType enum
        MeasurementType measurementType;
        if (measurement is int) {
          // Map the integer value to the corresponding MeasurementType
          measurementType = intToMeasurementType(measurement);
        } else {
          // If it's not an integer, you may want to handle the case (e.g., return 'unit' or handle other types)
          measurementType = MeasurementType.kilogram; // Fallback to a default type if needed
        }

        // Convert MeasurementType to string for display (localized string)
        String measurementString = measurementTypeToStringNl(measurementType);

        return {
          'ingredientQuantityId': ingredient['ingredientQuantityId'],
          'ingredientName': ingredient['ingredient']['ingredientName'],
          'quantity': ingredient['quantity'],
          'measurement': measurementString, // Display the correct measurement string
        };
      }).toList();

      List<Map<String, dynamic>> parsedDataItems = items.map<Map<String, dynamic>>((ingredient) {
        var measurement = ingredient['ingredient']['measurement'];

        // Convert measurement integer to MeasurementType enum
        MeasurementType measurementType;
        if (measurement is int) {
          // Map the integer value to the corresponding MeasurementType
          measurementType = intToMeasurementType(measurement);
        } else {
          // If it's not an integer, you may want to handle the case (e.g., return 'unit' or handle other types)
          measurementType = MeasurementType.kilogram; // Fallback to a default type if needed
        }

        // Convert MeasurementType to string for display (localized string)
        String measurementString = measurementTypeToStringNl(measurementType);

        return {
          'ingredientQuantityId': ingredient['ingredientQuantityId'],
          'ingredientName': ingredient['ingredient']['ingredientName'],
          'quantity': ingredient['quantity'],
          'measurement': measurementString, // Display the correct measurement string
        };
      }).toList();

      setState(() {
        ingredientData = parsedData;  // Reassign with parsed ingredients
        ingredientData.addAll(parsedDataItems);  // Add items to ingredientData
      });

    }
  }

  void addItem(ItemQuantity newItem) async {
    setState(() {
      groceryList.add(newItem);
    });

    String? groceryListId = await groceryListService.getGroceryListId();
    if (groceryListId == null) {
      return;
    }
    groceryListService.addItemToGroceryList(groceryListId, newItem);
    groceryListService.deleteItemFromGroceryList("1d78e45d-0205-4150-bb66-48d8d7b10e5f", "a2b3c9a3-9040-49c0-b3b7-a1efc418a4ad");
  }

  List<Map<String, dynamic>> get combinedData {
    List<Map<String, dynamic>> combinedList = [];

    combinedList.addAll(ingredientData);

    combinedList.addAll(groceryList.map((item) {
      return {
        'ingredientQuantityId': item.itemQuantityId,
        'ingredientName': item.groceryListItem.ingredientName,
        'quantity': item.quantity,
        'measurement': item.groceryListItem.measurement.name,
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
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Using Table instead of DataTable to have Dismissible rows
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
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
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
                          setState(() {
                            if (ingredient['type'] == 'manual') {
                              // Manually added item
                              groceryList.removeWhere((item) =>
                              item.groceryListItem.ingredientName == ingredient['ingredientName']);
                            } else {
                              // Fetched item from API, handle accordingly
                              ingredientData.removeWhere((item) =>
                              item['ingredientName'] == ingredient['ingredientName']);
                            }
                            deleteItem(ingredient['ingredientQuantityId']);
                            isDeleting = true;
                          });

                          // Delay adding a new item until the item is fully removed from the list.
                          Future.delayed(Duration(milliseconds: 300), () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${ingredient['ingredientName']} is verwijderd'),
                                action: SnackBarAction(
                                  label: "Ongedaan maken",
                                  onPressed: () {
                                    setState(() {
                                      isDeleting = false;
                                      groceryList.add(ItemQuantity(
                                        itemQuantityId: '',
                                        quantity: ingredient['quantity'],
                                        groceryListItem: GroceryListItem(
                                          ingredientName: ingredient['ingredientName'],
                                          measurement: ingredient['measurement'],
                                          ingredientQuantities: [],
                                        ),
                                      ));
                                    });
                                  },
                                ),
                              ),
                            );
                          });
                        },
                        child: Table(
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      ingredient['ingredientName'],
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      ingredient['measurement'],
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      ingredient['quantity'].toString(),
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.delete, color: Colors.black, size: 30),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
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
                          return DialogInputGrocery(onAdd: (name, quantity, measurement) {
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
            child: const Text('Annuleer')
        ),
        TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final quantity = double.tryParse(quantityController.text.trim()) ?? 1.0;

              if (name.isNotEmpty && quantity > 0) {
                widget.onAdd(name, quantity, selectedMeasurement);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Voeg toe')
        )
      ],

      /*
      content: TextField(
        controller: controller,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuleer'),
        ),
        TextButton(
            onPressed: () {
              final String newItem = controller.text.trim();
              if (newItem.isNotEmpty) {
                widget.onAdd(newItem);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Voeg toe'))
      ],*/
    );
  }
}

Future<void> showEditDialog({
  required BuildContext context,
  required String currentItem,
  required List<String> groceryList,
  required Function(String) onItemUpdated,
}) async {
  TextEditingController controller = TextEditingController(text: currentItem);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Pas aan'),
        content: TextField(
          controller: controller,
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
              String updatedItem = controller.text.trim();
              if (updatedItem.isNotEmpty && updatedItem != currentItem) {
                onItemUpdated(updatedItem);
              }
              Navigator.pop(context);
            },
            child: const Text('Opslaan'),
          ),
        ],
      );
    },
  );
}