import 'package:flutter/material.dart';
import 'package:ecommerce/models/review_model.dart';
import 'package:ecommerce/services/review_service.dart';

class ProductReviewPage extends StatefulWidget {
  final int productId;
  final String productName;

  const ProductReviewPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ProductReviewPage> createState() => _ProductReviewPageState();
}

class _ProductReviewPageState extends State<ProductReviewPage> {
  final TextEditingController _reviewController = TextEditingController();

  int _selectedRating = 5;
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<ReviewModel> _reviews = [];

  // 🎨 Tema Lilac
  final Color lilacPrimary = const Color(0xFFC8A2C8);
  final Color lilacDark = const Color(0xFF9575CD);
  final Color lilacLight = const Color(0xFFF3E5F5);

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  // ================= FETCH REVIEW =================
  Future<void> _fetchReviews() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final data =
        await ReviewService.getReviewsByProduct(widget.productId);

    debugPrint("PRODUCT ID: ${widget.productId}");
    debugPrint("TOTAL REVIEW USER: ${data.length}");

    if (mounted) {
      setState(() {
        _reviews = data;
        _isLoading = false;
      });
    }
  }

  // ================= SUBMIT REVIEW =================
  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ulasan tidak boleh kosong")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final review = ReviewModel(
      productId: widget.productId,
      review: _reviewController.text.trim(),
      rating: _selectedRating,
    );

    final success = await ReviewService.postReview(review);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      _reviewController.clear();
      setState(() => _selectedRating = 5);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ulasan berhasil dikirim")),
      );

      // 🔄 Refresh review
      _fetchReviews();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengirim ulasan")),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final reversedReviews = _reviews.reversed.toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.productName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [lilacDark, lilacPrimary],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ===== LIST REVIEW =====
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: lilacPrimary),
                  )
                : reversedReviews.isEmpty
                    ? const Center(
                        child: Text("Belum ada ulasan"),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchReviews,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: reversedReviews.length,
                          itemBuilder: (context, index) {
                            final review = reversedReviews[index];
                            return _buildReviewCard(review);
                          },
                        ),
                      ),
          ),

          // ===== FORM REVIEW =====
          _buildWriteReviewSection(),
        ],
      ),
    );
  }

  // ================= REVIEW CARD =================
  Widget _buildReviewCard(ReviewModel review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: lilacLight,
              child: Icon(Icons.person, color: lilacDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < review.rating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.review,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WRITE REVIEW =================
  Widget _buildWriteReviewSection() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Berikan Penilaian Anda",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),

          // ⭐ Rating Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() => _selectedRating = index + 1),
                icon: Icon(
                  index < _selectedRating
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
            ),
          ),

          TextField(
            controller: _reviewController,
            maxLines: 2,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              hintText: "Tulis ulasan produk...",
              filled: true,
              fillColor: lilacLight.withOpacity(0.3),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: lilacPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "KIRIM ULASAN",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
