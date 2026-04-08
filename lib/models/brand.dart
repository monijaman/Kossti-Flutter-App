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
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      nameBn: (json['name_bn'] ?? json['name'])?.toString() ?? '',
      description: json['description']?.toString(),
      descriptionBn: json['description_bn']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      websiteUrl: json['website_url']?.toString(),
      slug: (json['slug'] ?? json['id'].toString()).toString(),
      productCount: (json['product_count'] as num?)?.toInt() ?? 0,
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
