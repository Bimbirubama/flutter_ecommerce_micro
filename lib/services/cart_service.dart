import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartService {
  static const String _cartKey = 'user_cart';

  // 1. AMBIL DATA KERANJANG
  static Future<List<CartItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString(_cartKey);
    
    if (cartData == null || cartData.isEmpty) return [];
    
    try {
      // Mengonversi string JSON menjadi List<CartItem>
      final List<dynamic> decoded = jsonDecode(cartData);
      return decoded.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      print("Error decoding cart: $e");
      return [];
    }
  }

  // 2. TAMBAH PESANAN
  static Future<void> addToCart(ProductModel product) async {
    List<CartItem> cart = await getCart();
    
    try {
      // Gunakan .firstWhere agar lebih aman, atau indexWhere
      int index = cart.indexWhere((item) => item.product.id == product.id);
      
      if (index != -1) {
        // Jika sudah ada, buat objek baru dengan quantity bertambah
        // (Immutability lebih baik untuk state management)
        cart[index].quantity += 1;
      } else {
        cart.add(CartItem(product: product, quantity: 1));
      }
      
      await _saveCart(cart);
    } catch (e) {
      print("Error adding to cart: $e");
    }
  }

  // 3. KURANGI JUMLAH (HANYA KURANGI 1)
  static Future<void> removeFromCart(int productId) async {
    List<CartItem> cart = await getCart();
    int index = cart.indexWhere((item) => item.product.id == productId);
    
    if (index != -1) {
      if (cart[index].quantity > 1) {
        cart[index].quantity -= 1;
      } else {
        // Jika sisa 1, hapus dari list
        cart.removeAt(index);
      }
      await _saveCart(cart);
    }
  }

  // 4. HAPUS TOTAL (DELETE)
  // Ini fungsi yang Anda tanyakan agar benar-benar berfungsi menghapus baris produk
  static Future<void> deleteItem(int productId) async {
    List<CartItem> cart = await getCart();
    
    // Pastikan membandingkan dengan tipe data yang sama (int)
    // removeWhere akan menghapus semua item yang id-nya cocok
    cart.removeWhere((item) => item.product.id == productId);
    
    await _saveCart(cart);
  }

  // 5. SIMPAN KE PENYIMPANAN LOKAL
  static Future<void> _saveCart(List<CartItem> cart) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Pastikan Model CartItem memiliki method toJson()
      String encodedData = jsonEncode(cart.map((e) => e.toJson()).toList());
      await prefs.setString(_cartKey, encodedData);
    } catch (e) {
      print("Error saving cart: $e");
    }
  }

  // 6. KOSONGKAN KERANJANG
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}