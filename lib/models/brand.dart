class Brand {
  final int id;
  final String name;
  final String nameBn;
  final String? description;
  final String? descriptionBn;
  final String? logoUrl;
  final String? websiteUrl;
  final String slug;
  final int productCount;

  Brand({
    required this.id,
    required this.name,
    required this.nameBn,
    this.description,
    this.descriptionBn,
    this.logoUrl,
    this.websiteUrl,
    required this.slug,
    this.productCount = 0,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as int,
      name: json['name'] as String,
      nameBn: (json['name_bn'] ?? json['name']) as String,
      description: json['description'] as String?,
      descriptionBn: json['description_bn'] as String?,
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
      'name_bn': nameBn,
      'description': description,
      'description_bn': descriptionBn,
      'logo_url': logoUrl,
      'website_url': websiteUrl,
      'slug': slug,
      'product_count': productCount,
    };
  }

  String localizedName(String locale) =>
      locale == 'bn' ? nameBn : name;

  String? localizedDescription(String locale) =>
      locale == 'bn' ? descriptionBn : description;
}
