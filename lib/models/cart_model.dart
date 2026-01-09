import 'product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// 🔥 Simpan cart ke SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(), // product SUDAH menyimpan id
      'quantity': quantity,
    };
  }

  /// 🔥 Ambil cart dari SharedPreferences
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(
        Map<String, dynamic>.from(json['product']),
      ),
      quantity: json['quantity'] ?? 1,
    );
  }
}
