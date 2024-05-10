import 'dart:typed_data';

class Item {
  final String title;
  final String description;
  final int price;
  final String imgName;
  final int id;
  Uint8List imageUrl;

  Item({
    required this.title,
    required this.description,
    required this.price,
    required this.imgName,
    required this.id,
    required this.imageUrl,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      title: json['title'],
      description: json['description'],
      price: json['price'],
      imgName: json['img_name'],
      id: json['id'],
      imageUrl: Uint8List(0), 
    );
  }
}
