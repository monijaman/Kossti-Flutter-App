class Brand {
  final int id;
  final String name;
  final String nameAr;
  final String? description;
  final String? descriptionAr;
  final String? logoUrl;
  final String? websiteUrl;
  final String slug;
  final int productCount;

  Brand({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.descriptionAr,
    this.logoUrl,
    this.websiteUrl,
    required this.slug,
    this.productCount = 0,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as int,
      name: json['name'] as String,
      nameAr: (json['name_ar'] ?? json['name']) as String,
      description: json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      logoUrl: json['logo_url'] as String?,
      websiteUrl: json['website_url'] as String?,
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
      'logo_url': logoUrl,
      'website_url': websiteUrl,
      'slug': slug,
      'product_count': productCount,
    };
  }

  String localizedName(String locale) =>
      locale == 'ar' ? nameAr : name;

  String? localizedDescription(String locale) =>
      locale == 'ar' ? descriptionAr : description;
}
