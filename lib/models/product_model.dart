class ProductModel {
  final int? id;
  final String name;
  final double price;
  final String description;

  ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'], // 🔥 AMBIL ID
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // 🔥 SIMPAN ID (INI KUNCI)
      'name': name,
      'price': price,
      'description': description,
    };
  }
}
