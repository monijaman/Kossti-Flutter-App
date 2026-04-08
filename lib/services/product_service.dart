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
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': AppConstants.pageSize.toString(),
    };
    if (categoryId != null) params['category_id'] = categoryId.toString();
    if (brandId != null) params['brand_id'] = brandId.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (sortBy != null) params['sort_by'] = sortBy;
    if (minRating != null) params['min_rating'] = minRating.toString();

    final response = await _apiClient.get(
      AppConstants.productsEndpoint,
      queryParams: params,
    );
    return ApiClient.extractList(response)
        .map((p) => Product.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> getFeaturedProducts() async {
    final response = await _apiClient.get(
      '${AppConstants.productsEndpoint}/featured',
    );
    return ApiClient.extractList(response)
        .map((p) => Product.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProduct(int id) async {
    final response = await _apiClient.get(
      '${AppConstants.productsEndpoint}/$id',
    );
    return Product.fromJson(response as Map<String, dynamic>);
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
}
