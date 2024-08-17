class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;

  Product(
      {required this.id,
      required this.name,
      required this.price,
      required this.description,
      required this.imageUrl});
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
