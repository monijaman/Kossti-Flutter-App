class Category {
  final int id;
  final String name;
  final String nameAr;
  final String? description;
  final String? descriptionAr;
  final String? imageUrl;
  final String slug;
  final int productCount;

  Category({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.descriptionAr,
    this.imageUrl,
    required this.slug,
    this.productCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      nameAr: (json['name_ar'] ?? json['name']) as String,
      description: json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      imageUrl: json['image_url'] as String?,
      slug: (json['slug'] ?? json['id'].toString()) as String,
      productCount: (json['product_count'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'description_ar': descriptionAr,
      'image_url': imageUrl,
      'slug': slug,
      'product_count': productCount,
    };
  }

  String localizedName(String locale) =>
      locale == 'ar' ? nameAr : name;

  String? localizedDescription(String locale) =>
      locale == 'ar' ? descriptionAr : description;
}
