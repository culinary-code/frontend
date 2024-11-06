import 'package:flutter/material.dart';

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
          Text(
            "Boodschappenlijst",
            style: TextStyle(
              fontSize: 25,
            ),
          ),
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
  late final List<String> groceryList = [
    "1 stuk savooi",
    "500g gehakt",
    "600g aardappelen"
  ];

  void _addItem(String newItem) {
    setState(() {
      groceryList.add(newItem);
    });
  }

  void _deleteItem(String item) {
    setState(() {
      groceryList.remove(item);
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
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Boodschappenlijst',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                          ),
                        ),
                      ),
                    ]),
                ...groceryList.map((groceryItem) {
                  return TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Dismissible(
                            key: Key(groceryItem),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              _deleteItem(groceryItem);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('$groceryItem verwijderd')));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                groceryItem,
                                style: const TextStyle(fontSize: 22),
                              ),
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
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return DialogInputGrocery(onAdd: (newItem) {
                              _addItem(newItem);
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
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Wat wil je toevoegen?'),
      content: TextField(
        controller: _controller,
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
              final String newItem = _controller.text.trim();
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
