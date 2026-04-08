import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/product.dart';

class ProductService {
  final ApiClient _apiClient;

  ProductService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Product>> getProducts({
    int page = 1,
    int? categoryId,
    int? brandId,
    String? search,
    String? sortBy,
    double? minRating,
    String locale = 'en',
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': AppConstants.pageSize.toString(),
      'locale': locale,
    };
    if (categoryId != null) params['category'] = categoryId.toString();
    if (brandId != null) params['brand'] = brandId.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (sortBy != null) params['sortby'] = sortBy;
    if (minRating != null) params['min_rating'] = minRating.toString();

    final response = await _apiClient.get(
      AppConstants.productsEndpoint,
      queryParams: params,
    );
    final List<dynamic> data =
        response['products'] as List<dynamic>? ??
        response['data'] as List<dynamic>? ??
        response as List<dynamic>;
    print('API products response: $response');
    return data
        .map((p) => Product.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> getFeaturedProducts() async {
    final response = await _apiClient.get(
      AppConstants.popularProductsEndpoint,
    );
    final List<dynamic> data =
        response['products'] as List<dynamic>? ??
        response['data'] as List<dynamic>? ??
        response as List<dynamic>;
    return data
        .map((p) => Product.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProduct(int id, {String locale = 'en'}) async {
    final params = <String, String>{
      'type': 'public',
      'locale': locale,
    };
    final response = await _apiClient.get(
      '${AppConstants.productsEndpoint}/$id',
      queryParams: params,
    );
    // Handle various response formats
    final data = response['product'] as Map<String, dynamic>? ??
        response['data'] as Map<String, dynamic>? ??
        response as Map<String, dynamic>;
    print('API product detail response: $response');
    return Product.fromJson(data);
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      AppConstants.productsEndpoint,
      body: data,
    );
    return Product.fromJson(response as Map<String, dynamic>);
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '${AppConstants.productsEndpoint}/$id',
      body: data,
    );
    return Product.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int id) async {
    await _apiClient.delete('${AppConstants.productsEndpoint}/$id');
  }

  Future<List<String>> getProductImages(int productId) async {
    try {
      final response = await _apiClient.get('/productimages/$productId');
      final List<dynamic> images = response['images'] as List<dynamic>? ?? [];
      final urls = <String>[];
      // Put default photo first
      final sorted = [...images]..sort((a, b) {
          final aDefault = (a['defaultphoto'] ?? 0) as int;
          final bDefault = (b['defaultphoto'] ?? 0) as int;
          return bDefault.compareTo(aDefault);
        });
      for (final img in sorted) {
        final url = img['url'] as String? ?? img['asset_url'] as String?;
        if (url != null && url.isNotEmpty) urls.add(url);
      }
      return urls;
    } catch (e) {
      print('Error fetching product images: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPublicSpecifications(int productId, {String locale = 'en'}) async {
    final params = <String, String>{
      'locale': locale,
    };
    try {
      final response = await _apiClient.get(
        '${AppConstants.publicSpecEndpoint}/$productId',
        queryParams: params,
      );
      // API returns {"dataset": [...]}
      final List<dynamic> data =
          response['dataset'] as List<dynamic>? ??
          response['specifications'] as List<dynamic>? ??
          response['data'] as List<dynamic>? ??
          [];
      return data.map((s) => s as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching public specifications: $e');
      return [];
    }
  }
}
