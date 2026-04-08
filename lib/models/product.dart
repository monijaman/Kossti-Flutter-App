import 'category.dart';
import 'brand.dart';
import 'review.dart';

class Product {
  final int id;
  final String name;
  final String nameAr;
  final String? description;
  final String? descriptionAr;
  final double price;
  final String? imageUrl;
  final List<String> images;
  final Category? category;
  final Brand? brand;
  final double averageRating;
  final int reviewCount;
  final String slug;
  final bool isFeatured;
  final bool isActive;
  final DateTime? createdAt;
  final List<Review> reviews;

  Product({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.descriptionAr,
    required this.price,
    this.imageUrl,
    this.images = const [],
    this.category,
    this.brand,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    required this.slug,
    this.isFeatured = false,
    this.isActive = true,
    this.createdAt,
    this.reviews = const [],
  });

  String get displayImage => imageUrl ?? (images.isNotEmpty ? images.first : '');

  String localizedName(String locale) =>
      locale == 'ar' ? nameAr : name;

  String? localizedDescription(String locale) =>
      locale == 'ar' ? descriptionAr : description;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      nameAr: (json['name_ar'] ?? json['name']) as String,
      description: json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : [],
      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      brand: json['brand'] != null
          ? Brand.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      reviewCount: (json['review_count'] ?? 0) as int,
      slug: (json['slug'] ?? json['id'].toString()) as String,
      isFeatured: (json['is_featured'] ?? false) as bool,
      isActive: (json['is_active'] ?? true) as bool,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((r) => Review.fromJson(r as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'description_ar': descriptionAr,
      'price': price,
      'image_url': imageUrl,
      'images': images,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'slug': slug,
      'is_featured': isFeatured,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
