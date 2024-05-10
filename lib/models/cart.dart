import 'dart:typed_data';

import 'package:kuis_webapi/models/item.dart';

class Cart {
  final int itemId;
  final int userId;
  final int quantity;
  final int id;

  Cart({
    required this.itemId,
    required this.userId,
    required this.quantity,
    required this.id,
  });

  factory Cart.fromJsoncart(Map<String, dynamic> json) {
    return Cart(
      itemId: json['item_id'],
      userId: json['user_id'],
      quantity: json['quantity'],
      id: json['id'],
    );
  }
  
  Item toItem() {
    // Temukan item yang cocok dengan ID dari objek Cart di dalam globalItems
    Item? matchedItem = globalItems.firstWhere(
      (item) => item.id == this.itemId,
      orElse: () => Item(
        title: 'Unknown',
        description: 'Unknown',
        price: 0,
        imgName: 'unknown.png',
        id: 0,
        imageUrl: Uint8List(0),
      ),
    );
    return matchedItem;
  }
}
