import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/auth_storage.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final AuthService _authService = AuthService();

  // Warna Tema Lilac
  final Color lilacPrimary = const Color(0xFFC8A2C8);
  final Color lilacDark = const Color(0xFF9575CD);
  final Color lilacLight = const Color(0xFFF3E5F5);

  void _refresh() => setState(() {});

  // Fungsi Dialog Edit Profil
  void _showEditDialog(int id, String currentName, String currentEmail) {
    final nameCtrl = TextEditingController(text: currentName);
    final emailCtrl = TextEditingController(text: currentEmail);

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
            Text("Perbarui Profil", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: lilacDark)),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Nama Lengkap",
                prefixIcon: Icon(Icons.person_outline, color: lilacPrimary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined, color: lilacPrimary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: lilacPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  final result = await _authService.updateProfile(id, nameCtrl.text, emailCtrl.text);
                  if (result['success']) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profil berhasil diperbarui"), backgroundColor: Colors.green),
                    );
                    _refresh();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [lilacDark, lilacPrimary])),
        ),
        automaticallyImplyLeading: false, // Menghilangkan tombol back karena sudah ada di Nav Bar
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _authService.getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: lilacPrimary));
          }

          if (snapshot.hasError || snapshot.data?['success'] == false) {
            return Center(child: Text("Gagal memuat profil. Silahkan login kembali."));
          }

          final user = snapshot.data?['data'];

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Profile (Avatar)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [lilacDark, lilacPrimary]),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: lilacLight,
                          child: Icon(Icons.person, size: 50, color: lilacDark),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                Text(
                  user['name'] ?? "User",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: lilacDark),
                ),
                Text(user['email'] ?? "", style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 30),

                // Menu Opsi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildMenuTile(
                        icon: Icons.edit_outlined,
                        title: "Edit Profil",
                        onTap: () => _showEditDialog(user['id'], user['name'], user['email']),
                      ),
                      _buildMenuTile(
                        icon: Icons.help_outline,
                        title: "Pusat Bantuan",
                        onTap: () {},
                      ),
                      const SizedBox(height: 20),
                      
                      // Tombol Logout
                      GestureDetector(
                        onTap: () async {
                          await AuthStorage.logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.redAccent),
                              SizedBox(width: 10),
                              Text("Keluar dari Akun", 
                                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: ListTile(
        leading: Icon(icon, color: lilacPrimary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}