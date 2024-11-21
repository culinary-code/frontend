import 'package:frontend/models/meal_planning/grocery_list_item.dart';

class ItemQuantity {
  double quantity;
  final GroceryListItem groceryListItem;

  ItemQuantity(
  {
  required this.quantity,
  required this.groceryListItem
  });
}