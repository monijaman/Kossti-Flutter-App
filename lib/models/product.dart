import 'category.dart';
import 'brand.dart';
import 'review.dart';

class Product {
  final int id;
  final String name;
  final String nameBn;
  final String? description;
  final String? descriptionBn;
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
    required this.nameBn,
    this.description,
    this.descriptionBn,
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
      locale == 'bn' ? nameBn : name;

  String? localizedDescription(String locale) =>
      locale == 'bn' ? descriptionBn : description;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      nameBn: (json['name_bn'] ?? json['name'])?.toString() ?? '',
      description: json['description']?.toString(),
      descriptionBn: json['description_bn']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['image_url']?.toString(),
      images: json['images'] != null
          ? List<String>.from((json['images'] as List).map((e) => e.toString()))
          : [],
      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      brand: json['brand'] != null
          ? Brand.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      averageRating:
          double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      slug: (json['slug'] ?? json['id'].toString()).toString(),
      isFeatured: _parseBool(json['is_featured']) ?? false,
      isActive: _parseBool(json['is_active']) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((r) => Review.fromJson(r as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == 'true' || value == '1';
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_bn': nameBn,
      'description': description,
      'description_bn': descriptionBn,
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
