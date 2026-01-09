import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/auth_storage.dart'; // Import storage Anda
import '../config/api.dart';

class UserService {
  // static const String baseUrl = "http://192.168.18.72:8000/users";

  static Future<List<User>> getAllUsers() async {
    try {
      String? token = await AuthStorage.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Jika backend mengirim {"success": true, "data": [...]}, ambil decoded['data']
        List data = (decoded is Map) ? (decoded['data'] ?? []) : decoded;
        return data.map((e) => User.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
