import 'package:frontend/models/meal_planning/grocery_list_item.dart';

class ItemQuantity {
  String itemQuantityId;
  double quantity;
  final GroceryListItem groceryListItem;
  bool isIngredient;

  ItemQuantity(
      {required this.itemQuantityId,
      required this.quantity,
      required this.groceryListItem, required this.isIngredient
      });
}
