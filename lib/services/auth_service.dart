import 'dart:convert';
import 'package:ecommerce/models/user_model.dart';
import 'package:flutter/foundation.dart'; // <--- WAJIB UNTUK debugPrint
import 'package:http/http.dart' as http;
import '../utils/auth_storage.dart';

class AuthService {
  // Gunakan IP Laptop Anda (Pastikan HP & Laptop di WiFi yang sama)
  static const String baseUrl = 'http://192.168.18.72:4000';

  // 1. REGISTER
  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Register error: $e'};
    }
  }

  // 2. LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        // Simpan token dan role secara lokal
        await AuthStorage.saveAuthData(
          data['data']['token'],
          data['data']['role'],
        );
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Login error: $e'};
    }
  }

  // 3. GET PROFILE (ME)
  Future<Map<String, dynamic>> getProfile() async {
    try {
      String? token = await AuthStorage.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil profil: $e'};
    }
  }

  // 4. UPDATE PROFILE
  Future<Map<String, dynamic>> updateProfile(int id, String name, String email) async {
    try {
      String? token = await AuthStorage.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal update profil: $e'};
    }
  }

  // 5. GET ALL USERS (Khusus Admin)
  Future<List<User>> getAllUsers() async {
  try {
    String? token = await AuthStorage.getToken(); // Ambil token JWT
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final decoded = jsonDecode(response.body);

    // Cek apakah response success dan ada field 'data'
    if (response.statusCode == 200 && decoded['success'] == true) {
      List data = decoded['data'];
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      debugPrint("Gagal mengambil user: ${decoded['message']}");
      return [];
    }
  } catch (e) {
    debugPrint("Error getAllUsers: $e");
    return [];
  }

}

  // 6. DELETE USER (Khusus Admin)
  Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      String? token = await AuthStorage.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghapus user: $e'};
    }
  }
}