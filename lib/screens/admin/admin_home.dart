import 'package:flutter/material.dart';
import '../../utils/auth_storage.dart';
import '../../services/product_service.dart';
import '../../services/user_service.dart'; // Untuk List User
import '../../services/review_service.dart'; // Untuk List Review
import '../../services/auth_service.dart'; // Tambahkan ini
import 'product_manage_page.dart';
import 'admin_profile_page.dart';
import 'review_list_page.dart'; // Sesuaikan nama filenya
import 'admin_user_list_page.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  // Warna Tema Lilac
  final Color lilacPrimary = const Color(0xFFC8A2C8);
  final Color lilacDark = const Color(0xFF9575CD);
  final Color lilacLight = const Color(0xFFF3E5F5);

  // Inisialisasi Service
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();

  // State Data
  int _totalProducts = 0;
  int _totalUsers = 0;
  int _totalReviews = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllStats();
  }

  // Fungsi untuk mengambil semua data statistik secara paralel
  Future<void> _fetchAllStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _productService.getAllProducts(),
        UserService.getAllUsers(),
        ReviewService.getAllReviews(),
      ]);

      if (mounted) {
        setState(() {
          _totalProducts = (results[0] as List).length;
          _totalUsers = (results[1] as List).length;
          _totalReviews = (results[2] as List).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Error Fetching Stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [lilacDark, lilacPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchAllStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthStorage.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      // Drawer
      drawer: Drawer(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _authService.getProfile(), // ambil data user dari API
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null || snapshot.data!['success'] != true) {
              return const Center(child: Text("Gagal mengambil data user"));
            }

            final userData = snapshot.data!['data'];
            final name = userData['name'] ?? 'Admin';
            final email = userData['email'] ?? '-';
            final role = userData['role'] ?? '-';

            return Column(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: lilacPrimary),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Color(0xFF9575CD)),
                  ),
                  accountName: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(email),
                  otherAccountsPictures: [
                    CircleAvatar(
                      child: Text(role[0].toUpperCase()),
                      backgroundColor: Colors.white,
                      foregroundColor: lilacDark,
                    ),
                  ],
                ),

                _buildDrawerItem(Icons.dashboard, "Dashboard", () => Navigator.pop(context)),

                _buildDrawerItem(Icons.person_outline, "Profil Saya", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminProfilePage()),
                  );
                }),

                _buildDrawerItem(Icons.people, "List User", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminUserListPage()),
                  );
                }),

                _buildDrawerItem(Icons.inventory, "Kelola Produk", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductManagePage()),
                  ).then((_) => _fetchAllStats());
                }),

                _buildDrawerItem(Icons.rate_review_outlined, "Daftar Review", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminReviewPage()),
                  );
                }),

                const Divider(),

                _buildDrawerItem(
                  Icons.logout,
                  "Logout",
                  () async {
                    await AuthStorage.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  color: Colors.redAccent,
                ),
              ],
            );
          },
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _fetchAllStats,
        color: lilacPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selamat Datang, Admin!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: lilacDark,
                ),
              ),
              const SizedBox(height: 20),

              // Row Statistik
              Row(
                children: [
                  _buildStatCard("Produk", _isLoading ? "..." : "$_totalProducts", Icons.shopping_bag,
                      onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProductManagePage()),
                          ).then((_) => _fetchAllStats())),
                  const SizedBox(width: 10),
                  _buildStatCard("Users", _isLoading ? "..." : "$_totalUsers", Icons.people,
                      onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminUserListPage()),
                          ).then((_) => _fetchAllStats())),
                  const SizedBox(width: 10),
                  _buildStatCard("Review", _isLoading ? "..." : "$_totalReviews", Icons.rate_review,
                      onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminReviewPage()),
                          ).then((_) => _fetchAllStats())),
                ],
              ),
              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: lilacLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(Icons.analytics_outlined, size: 50, color: lilacDark),
                    const SizedBox(height: 10),
                    const Text(
                      "Update Dashboard",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Data diperbarui secara real-time dari server.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Item Drawer
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? lilacDark),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

  // Widget helper untuk kartu statistik
  Widget _buildStatCard(String title, String count, IconData icon, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: lilacLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: lilacPrimary.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: lilacDark, size: 28),
              const SizedBox(height: 10),
              Text(
                count,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
