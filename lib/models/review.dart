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
      id: (json['id'] ?? 0) as int,
      productId: (json['product_id'] ?? 0) as int,
      author: json['author'] != null
          ? User.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      title: (json['title'] ?? '') as String,
      // API returns HTML content in 'reviews' field
      body: (json['reviews'] ?? json['body'] ?? json['content'] ?? '') as String,
      // API returns rating as string "3.50" or number
      rating: json['rating'] is String
          ? double.tryParse(json['rating'] as String) ?? 0.0
          : ((json['rating'] ?? 0) as num).toDouble(),
      // API returns status as bool (false/true) or string
      status: json['status'] is bool
          ? (json['status'] == true ? 'approved' : 'pending')
          : (json['status']?.toString() ?? 'approved'),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
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
