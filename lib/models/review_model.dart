class ReviewModel {
  final int? id;
  final int productId;
  final String review;
  final int rating;

  ReviewModel({
    this.id,
    required this.productId,
    required this.review,
    required this.rating,
  });

  // Untuk menerima data dari Flask (JSON -> Object)
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      productId: json['product_id'], // harus sesuai dengan backend
      review: json['review'],
      rating: json['rating'],
    );
  }

  // Untuk mengirim data ke Flask (Object -> JSON)
  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "review": review,
      "rating": rating,
    };
  }
}