import 'package:ecommerce/screens/user/review_page.dart';
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart'; // Import Service Keranjang
import 'cart_page.dart'; // Import Halaman Keranjang

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _service = ProductService();
  
  // Variabel untuk Pencarian & Data
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  int _cartCount = 0; // Untuk badge keranjang

  // Tema Warna Lilac
  final Color lilacPrimary = const Color(0xFFC8A2C8);
  final Color lilacDark = const Color(0xFF9575CD);
  final Color lilacLight = const Color(0xFFF3E5F5);

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _updateCartCount(); // Ambil jumlah item keranjang saat mulai
  }

  // Ambil data produk dari API
  Future<void> _fetchProducts() async {
    try {
      final products = await _service.getAllProducts();
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error Fetching Products: $e");
    }
  }

  // Ambil jumlah item di keranjang untuk badge
  Future<void> _updateCartCount() async {
    final cartItems = await CartService.getCart();
    int count = 0;
    for (var item in cartItems) {
      count += item.quantity;
    }
    setState(() {
      _cartCount = count;
    });
  }

  // Logika Pencarian
  void _runFilter(String query) {
    List<ProductModel> results = [];
    if (query.isEmpty) {
      results = _allProducts;
    } else {
      results = _allProducts
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {
      _filteredProducts = results;
    });
  }

  // Fungsi Tambah Keranjang
  void _addToCart(ProductModel product) async {
    await CartService.addToCart(product);
    await _updateCartCount(); // Update badge di AppBar
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} masuk keranjang!"),
        backgroundColor: lilacDark,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: "LIHAT",
          textColor: Colors.white,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPage()),
          ).then((_) => _updateCartCount()), // Refresh badge saat kembali dari keranjang
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Katalog Produk",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [lilacDark, lilacPrimary]),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            ).then((_) => _updateCartCount()), // Refresh badge saat kembali
            child: Padding(
              padding: const EdgeInsets.only(right: 15, top: 5),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
                  if (_cartCount > 0)
                    Positioned(
                      right: 0,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$_cartCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // BAR PENCARIAN
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                hintText: "Cari produk impianmu...",
                prefixIcon: Icon(Icons.search, color: lilacPrimary),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear), 
                      onPressed: () {
                        _searchController.clear();
                        _runFilter('');
                      }) 
                  : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // DAFTAR PRODUK
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: lilacPrimary))
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          "Produk tidak ditemukan...",
                          style: TextStyle(color: lilacDark, fontSize: 16),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchProducts,
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68, // Disesuaikan agar muat
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final p = _filteredProducts[index];
                            return _buildProductCard(p);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: lilacLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Icon(Icons.image, size: 50, color: lilacPrimary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Rp ${p.price}",
                  style: TextStyle(color: lilacDark, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  p.description,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 10),
               // Tombol Ulasan
TextButton(
  style: TextButton.styleFrom(
    padding: EdgeInsets.zero,
    minimumSize: const Size(0, 30),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  ),
  onPressed: () {
    // Navigasi ke Halaman Review
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductReviewPage(
          productId: p.id!, // Mengambil ID dari ProductModel
          productName: p.name, // Mengambil Nama dari ProductModel
        ),
      ),
    );
  },
  child: Text(
    "Lihat & Tulis Ulasan",
    style: TextStyle(
      color: lilacDark, 
      fontWeight: FontWeight.bold, 
      fontSize: 11 // Ukuran agak diperkecil agar pas di grid
    ),
  ),
),
                SizedBox(
                  width: double.infinity,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(p),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lilacPrimary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_shopping_cart, size: 14),
                        SizedBox(width: 5),
                        Text("Beli", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}