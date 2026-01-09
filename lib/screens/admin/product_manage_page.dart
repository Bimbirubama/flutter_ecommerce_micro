import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';

class ProductManagePage extends StatefulWidget {
  const ProductManagePage({super.key});

  @override
  State<ProductManagePage> createState() => _ProductManagePageState();
}

class _ProductManagePageState extends State<ProductManagePage> {
  final ProductService _service = ProductService();
  
  // Tema Warna Lilac
  final Color lilacPrimary = const Color(0xFFC8A2C8);
  final Color lilacDark = const Color(0xFF9575CD);
  final Color lilacLight = const Color(0xFFF3E5F5);

  void _refresh() => setState(() {});

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }

  // Dialog Konfirmasi Hapus
  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Produk"),
        content: Text("Yakin ingin menghapus '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              bool success = await _service.deleteProduct(id);
              Navigator.pop(context);
              if (success) {
                _showSnackBar("Produk dihapus", Colors.green);
                _refresh();
              } else {
                _showSnackBar("Gagal menghapus", Colors.red);
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Form Bottom Sheet (Tambah & Edit)
  void _showProductForm({ProductModel? product}) {
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final priceCtrl = TextEditingController(text: product?.price.toString() ?? '');
    final descCtrl = TextEditingController(text: product?.description ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20, left: 20, right: 20
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: lilacLight, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(product == null ? "Tambah Produk" : "Edit Produk", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: lilacDark)),
            const SizedBox(height: 20),
            _buildInput(nameCtrl, "Nama Produk", Icons.shopping_bag_outlined),
            const SizedBox(height: 15),
            _buildInput(priceCtrl, "Harga (Rp)", Icons.attach_money, isNumber: true),
            const SizedBox(height: 15),
            _buildInput(descCtrl, "Deskripsi", Icons.notes, maxLines: 3),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: lilacPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
                    _showSnackBar("Nama & Harga wajib diisi", Colors.orange);
                    return;
                  }
                  final p = ProductModel(
                    name: nameCtrl.text,
                    price: double.tryParse(priceCtrl.text) ?? 0,
                    description: descCtrl.text,
                  );
                  bool success = (product == null) ? await _service.addProduct(p) : await _service.updateProduct(product.id!, p);
                  if (success) {
                    Navigator.pop(context);
                    _showSnackBar("Berhasil disimpan", Colors.green);
                    _refresh();
                  } else {
                    _showSnackBar("Gagal menyimpan ke server", Colors.red);
                  }
                },
                child: const Text("SIMPAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: lilacPrimary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: lilacLight)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Stok", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [lilacDark, lilacPrimary]))),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _service.getAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: lilacPrimary));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Belum ada data produk."));

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final p = snapshot.data![index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  leading: CircleAvatar(backgroundColor: lilacLight, child: Icon(Icons.inventory, color: lilacDark)),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Rp ${p.price}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showProductForm(product: p)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(p.id!, p.name)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: lilacDark,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showProductForm(),
      ),
    );
  }
}