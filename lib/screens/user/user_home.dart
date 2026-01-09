import 'package:flutter/material.dart';
// Import halaman-halaman yang sudah dibuat sebelumnya
import 'product_list_page.dart';
// import 'cart_page.dart';
import 'user_profile_page.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _currentIndex = 0;

  // Warna Tema Lilac Konsisten
  final Color lilacPrimary = const Color(0xFFC8A2C8);
  final Color lilacDark = const Color(0xFF9575CD);
  final Color lilacLight = const Color(0xFFF3E5F5);

  // Fungsi untuk berpindah tab (digunakan oleh UserHomeBody)
  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // List halaman utama aplikasi
    final List<Widget> _pages = [
      UserHomeBody(onNavigateToKatalog: () => _changeTab(1)), // Index 0
      const ProductListPage(),  // Index 1      // Index 2
      const UserProfilePage(),  // Index 3
    ];

    return Scaffold(
      // IndexedStack menjaga "state" halaman agar tidak reset saat pindah tab
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: lilacDark,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: "Katalog",
          ),
         BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profil",
          ),
          
        ],
      ),
    );
  }
}

// --- WIDGET DASHBOARD BERANDA ---
class UserHomeBody extends StatelessWidget {
  final VoidCallback onNavigateToKatalog;
  
  const UserHomeBody({super.key, required this.onNavigateToKatalog});

  @override
  Widget build(BuildContext context) {
    const Color lilacPrimary = Color(0xFFC8A2C8);
    const Color lilacDark = Color(0xFF9575CD);
    const Color lilacLight = Color(0xFFF3E5F5);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Gradient dengan Greeting
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [lilacDark, lilacPrimary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Halo, Cantik!",
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Siap tampil memukau dengan Lilac hari ini?",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Visual Search Bar yang mengarah ke tab Katalog
                GestureDetector(
                  onTap: onNavigateToKatalog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: lilacPrimary),
                        SizedBox(width: 15),
                        Text(
                          "Cari koleksi impianmu...",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 2. Kategori Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text("Kategori Populer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCategoryItem(Icons.checkroom, "Gaun", lilacLight, lilacDark, onNavigateToKatalog),
              _buildCategoryItem(Icons.auto_awesome, "Aksesoris", lilacLight, lilacDark, onNavigateToKatalog),
              _buildCategoryItem(Icons.card_giftcard, "Kado", lilacLight, lilacDark, onNavigateToKatalog),
              _buildCategoryItem(Icons.grid_view_rounded, "Lainnya", lilacLight, lilacDark, onNavigateToKatalog),
            ],
          ),

          const SizedBox(height: 35),

          // 3. Banner Promo Horizontal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Promo Spesial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: onNavigateToKatalog,
                  child: const Text("Lihat Semua", style: TextStyle(color: lilacDark, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 25),
              itemCount: 3,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: onNavigateToKatalog,
                  child: Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(colors: [lilacLight, Colors.white]),
                      border: Border.all(color: lilacPrimary.withOpacity(0.3)),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -10, bottom: -10,
                          child: Icon(Icons.local_offer, size: 100, color: lilacPrimary.withOpacity(0.1)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: lilacDark, borderRadius: BorderRadius.circular(8)),
                                child: const Text("DISKON 50%", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 10),
                              const Text("Koleksi Musim Semi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const Text("Dapatkan harga terbaik sekarang!", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

        ],
      ),
    );
  }

  // Widget Helper untuk Kategori
  Widget _buildCategoryItem(IconData icon, String label, Color bg, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}