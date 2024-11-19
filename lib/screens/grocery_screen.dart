import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/ingredients/ingredient.dart';
import 'package:frontend/models/recipes/ingredients/item_quantity.dart';
import 'package:frontend/models/recipes/ingredients/measurement_type.dart';
import 'package:frontend/services/account_service.dart';
import 'package:uuid/uuid.dart';

import '../Services/keycloak_service.dart';
import '../models/groceryListItem.dart';
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
        child: Column(children: [
          SizedBox(
            height: 16,
          ),
          GroceryList()
        ]));
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
  final Uuid uuid = Uuid();
  final GroceryListService groceryListService = GroceryListService();
  final KeycloakService keycloakService = KeycloakService();
  final AccountService accountService = AccountService();



  /* late final List<String> groceryList = [
    "1 stuk savooi",
    "500g gehakt",
    "600g aardappelen",
    "1kg appels",
    "500g wortels",
  ];


  late final List<GroceryListItem> groceryList2 = [
    GroceryListItem(productName: "savooi", quantity: 1, measurement: "stuk"),
    GroceryListItem(productName: "gehakt", quantity: 500, measurement: "g"),
    GroceryListItem(
        productName: "aardappelen", quantity: 600, measurement: "g"),
  ];

  void addItem(String newItem) {
    setState(() {
      groceryList.add(newItem);
    });
  }*/

  void addItem(ItemQuantity newItem) async {
    setState(() {
      groceryList.add(newItem);
    });
    //addItemToGroceryList(newItem);

    final String id = '6ceed686-8784-4386-9a0b-899dd7fde3e3';
    Uuid.parse(id);

    String? userId = await groceryListService.getUserIdForGroceryList(id);
    String? groceryListId = await groceryListService.getGroceryListById(userId!);
    if (userId == null) {
      print('id: $userId');
      print('Failed to fetch grocery list ID');
      return;
    }
    groceryListService.addItemToGroceryList('15a3b9da-5564-4a68-8530-5cf2973fa501', newItem);
  }

  void deleteItem(ItemQuantity item) {
    setState(() {
      groceryList.remove(item);
      isDeleting = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Table(
              border: TableBorder.all(color: Colors.blueGrey.shade200),
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
                              Icon(Icons.shopping_cart, size: 30,)
                            ],
                          )

                          ,
                        ),
                      ),
                    ]),
                ...groceryList.map((item) {
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
                            key: Key(item.itemQuantityId),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              deleteItem(item);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('$item is verwijderd'),
                                action: SnackBarAction(
                                    label: "Ongedaan maken",
                                    onPressed: () {
                                      isUndoPressed = true;
                                      setState(() {
                                        isDeleting = false;
                                        groceryList.add(item);
                                      });
                                    }),
                              ));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    item.ingredient.ingredientName,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                                Container(
                                  color: Colors.red,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.keyboard_arrow_left, size: 30,),
                                      Icon(Icons.delete, color: Colors.black, size: 30,)
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
            Padding(padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      showDialog(context: context, builder: (context) {
                        return DialogInputGrocery(onAdd: (name, quantity, measurement) {
                          final newItem =
                          ItemQuantity(
                              itemQuantityId: uuid.v4(),
                              quantity: quantity,
                              ingredient: Ingredient(
                              ingredientId: uuid.v4(),
                                  ingredientName: name,
                                  measurement: measurement,
                                  ingredientQuantities: [],
                              ),
                          );
                          addItem(newItem);
                        });
                      });
                    }, 
                    icon: const Icon(Icons.add_box, size: 50),
                )
              ],
            ),)
            
            
            /*Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_box, size: 50),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return DialogInputGrocery(onAdd: (newItem) {
                              if (groceryList.contains(newItem)) {
                                Future.delayed(Duration.zero, () {
                                  if (!context.mounted) return;
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text(
                                              'Dit staat al op jouw lijstje, wil je dit aanpassen?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  showEditDialog(
                                                      context: context,
                                                      currentItem: newItem,
                                                      groceryList: groceryList,
                                                      onItemUpdated:
                                                          (updatedItem) {
                                                        setState(() {
                                                          int index =
                                                          groceryList
                                                              .indexOf(
                                                              newItem);
                                                          if (index != -1) {
                                                            groceryList[index] =
                                                                updatedItem;
                                                          }
                                                        });
                                                      });
                                                },
                                                child: const Text('Ja')),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Nee')),
                                          ],
                                        );
                                      });
                                });
                              } else {
                                addItem(newItem);
                              }
                            });
                          });
                    },
                  ),
                ],
              ),
            ),*/
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
  MeasurementType selectedMeasurement = MeasurementType.piece;

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

Future<void> addItemToGroceryList(ItemQuantity item) async {
  print('Adding item: ${item.ingredient.ingredientName}, Quantity: ${item.quantity}');
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
          /*decoration:
          const InputDecoration(hintText: "Wat wil je aanpassen?"),*/
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