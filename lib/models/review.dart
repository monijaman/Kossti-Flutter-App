import 'user.dart';

class Review {
  final int id;
  final int productId;
  final User? author;
  final String title;
  final String body;
  final double rating;
  final String status;
  final DateTime? createdAt;
  final int helpfulCount;

  Review({
    required this.id,
    required this.productId,
    this.author,
    required this.title,
    required this.body,
    required this.rating,
    this.status = 'pending',
    this.createdAt,
    this.helpfulCount = 0,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: (json['id'] as num).toInt(),
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      author: json['author'] != null
          ? User.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? json['content'] ?? '').toString(),
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      status: (json['status'] ?? 'pending').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      helpfulCount: (json['helpful_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'title': title,
      'body': body,
      'rating': rating,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'helpful_count': helpfulCount,
    };
  }
}
