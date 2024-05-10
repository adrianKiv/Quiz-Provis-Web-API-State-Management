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
}
