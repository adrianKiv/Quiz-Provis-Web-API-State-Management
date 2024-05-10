class Item {
  final int id;
  final String title;
  final String description;
  final int price;
  final String imgName;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imgName,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      imgName: json['img_name'],
    );
  }
}
