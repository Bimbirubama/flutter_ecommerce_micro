import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';

class ReviewService {
  // ✅ BASE URL TANPA /reviews
  static const String baseUrl = "http://192.168.18.72:5002";

  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  // ===============================
  // 1️⃣ AMBIL REVIEW PER PRODUK
  // GET /review/product/:id
  // ===============================
static Future<List<ReviewModel>> getReviewsByProduct(int productId) async {
  try {
    final response = await http.get(
      Uri.parse("$baseUrl/reviews"),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List data = decoded['data'];

      // 🔥 FILTER DI FLUTTER
      final filtered = data
          .where((e) => e['product_id'] == productId)
          .toList();

      return filtered
          .map((e) => ReviewModel.fromJson(e))
          .toList();
    }

    return [];
  } catch (e) {
    print("ERROR GET REVIEWS BY PRODUCT: $e");
    return [];
  }
}


  // ===============================
  // 2️⃣ AMBIL SEMUA REVIEW (ADMIN)
  // GET /reviews
  // ===============================
  static Future<List<ReviewModel>> getAllReviews() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/reviews"),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List data = decoded['data'];
        return data.map((e) => ReviewModel.fromJson(e)).toList();
      }

      print("GET ALL REVIEWS FAILED: ${response.body}");
      return [];
    } catch (e) {
      print("ERROR GET ALL REVIEWS: $e");
      return [];
    }
  }

  // ===============================
  // 3️⃣ KIRIM REVIEW BARU
  // POST /reviews
  // ===============================
  static Future<bool> postReview(ReviewModel review) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/reviews"),
        headers: _headers,
        body: jsonEncode(review.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }

      print("POST REVIEW FAILED: ${response.body}");
      return false;
    } catch (e) {
      print("ERROR POST REVIEW: $e");
      return false;
    }
  }
}
