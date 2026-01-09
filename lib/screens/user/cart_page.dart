import 'package:flutter/material.dart';
import '../../models/cart_model.dart';
import '../../services/cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _cartItems = [];
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // Fungsi untuk memuat ulang data keranjang dan menghitung total
  Future<void> _loadCart() async {
    final items = await CartService.getCart();
    double total = 0;
    for (var item in items) {
      total += item.product.price * item.quantity;
    }
    setState(() {
      _cartItems = items;
      _totalPrice = total;
    });
  }

  // Dialog Konfirmasi Hapus
  void _confirmDelete(int productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Barang?"),
        content: Text("Apakah Anda yakin ingin menghapus '$productName' dari keranjang?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              await CartService.deleteItem(productId);
              Navigator.pop(context);
              _loadCart(); // Refresh UI
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  final Color lilacPrimary = const Color(0xFFC8A2C8);
  final Color lilacDark = const Color(0xFF9575CD);
  final Color lilacLight = const Color(0xFFF3E5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang Belanja", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [lilacDark, lilacPrimary]))),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return _buildCartItem(item);
                    },
                  ),
                ),
                _buildCheckoutSection(),
              ],
            ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Gambar/Icon Produk
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: lilacLight, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.shopping_bag, color: lilacPrimary),
            ),
            const SizedBox(width: 12),
            // Nama & Harga
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text("Rp ${item.product.price}", style: TextStyle(color: lilacDark, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Kontrol Jumlah (Tambah/Kurang)
            Row(
              children: [
                // Tombol Minus
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.remove_circle, color: item.quantity > 1 ? lilacPrimary : Colors.grey),
                  onPressed: () async {
                    await CartService.removeFromCart(item.product.id!);
                    _loadCart();
                  },
                ),
                Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                // Tombol Plus
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.add_circle, color: lilacPrimary),
                  onPressed: () async {
                    await CartService.addToCart(item.product);
                    _loadCart();
                  },
                ),
                // Tombol Hapus Total
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(item.product.id!, item.product.name),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.remove_shopping_cart_outlined, size: 80, color: lilacLight),
          const SizedBox(height: 15),
          const Text("Keranjang kosong nih...", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: lilacPrimary),
            child: const Text("CARI PRODUK", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Bayar:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text("Rp $_totalPrice", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: lilacDark)),
            ],
          ),
          
        ],
      ),
    );
  }
}