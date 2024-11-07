import 'package:flutter/material.dart';

import '../models/groceryListItem.dart';

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

  late final List<String> groceryList = [
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
  }

  void deleteItem(String item) {
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
                ...groceryList.map((groceryItem) {
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
                            key: Key(groceryItem),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              deleteItem(groceryItem);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('$groceryItem is verwijderd'),
                                action: SnackBarAction(
                                    label: "Ongedaan maken",
                                    onPressed: () {
                                      isUndoPressed = true;
                                      setState(() {
                                        isDeleting = false;
                                        groceryList.add(groceryItem);
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
                                    groceryItem,
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
            Padding(
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
            ),
          ],
        ),
      ),
    );
  }
}

class DialogInputGrocery extends StatefulWidget {
  final Function(String) onAdd;

  const DialogInputGrocery({super.key, required this.onAdd});

  @override
  State<DialogInputGrocery> createState() => _DialogInputGroceryState();
}

class _DialogInputGroceryState extends State<DialogInputGrocery> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Wat wil je toevoegen?'),
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
      ],
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