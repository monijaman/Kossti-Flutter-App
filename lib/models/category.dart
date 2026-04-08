class Category {
  final int id;
  final String name;
  final String nameAr;
  final String? description;
  final String? descriptionAr;
  final String? imageUrl;
  final String slug;
  final int productCount;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.descriptionAr,
    this.imageUrl,
    required this.slug,
    this.productCount = 0,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final active = status == 1 || status == true || status == '1';
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      nameAr: (json['name_ar'] ?? json['name']) as String,
      description: json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      imageUrl: json['image_url'] as String?,
      slug: (json['slug'] ?? json['id'].toString()) as String,
      productCount: (json['product_count'] ?? json['total'] ?? 0) as int,
      isActive: status == null ? true : active,
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
