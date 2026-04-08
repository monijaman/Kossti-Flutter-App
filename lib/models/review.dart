import 'user.dart';

class Review {
  final int id;
  final int productId;
  final User? author;
  final String title;
  final String body;
  final double rating;
  final String status;
  final DateTime createdAt;
  final int helpfulCount;

  Review({
    required this.id,
    required this.productId,
    this.author,
    required this.title,
    required this.body,
    required this.rating,
    this.status = 'pending',
    required this.createdAt,
    this.helpfulCount = 0,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      author: json['author'] != null
          ? User.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      title: (json['title'] ?? '') as String,
      body: (json['body'] ?? json['content'] ?? '') as String,
      rating: (json['rating'] as num).toDouble(),
      status: (json['status'] ?? 'pending') as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      helpfulCount: (json['helpful_count'] ?? 0) as int,
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
      'created_at': createdAt.toIso8601String(),
      'helpful_count': helpfulCount,
    };
  }
}
