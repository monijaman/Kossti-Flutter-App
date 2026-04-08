import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/brand.dart';

class BrandService {
  final ApiClient _apiClient;

  BrandService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Brand>> getBrands() async {
    final response = await _apiClient.get(AppConstants.brandsEndpoint);
    final List<dynamic> data =
        response['brands'] as List<dynamic>? ??
        response['data'] as List<dynamic>? ??
        response as List<dynamic>;
    return data
        .map((b) => Brand.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  Future<List<Brand>> getCategoryBrands(String categorySlug, {String locale = 'en'}) async {
    try {
      final response = await _apiClient.get(
        '/category-brands',
        queryParams: {'category_slug': categorySlug, 'locale': locale},
      );
      final List<dynamic> data =
          response['brands'] as List<dynamic>? ??
          response['data'] as List<dynamic>? ??
          (response is List ? response : []);
      return data
          .map((b) => Brand.fromJson(b as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching category brands: $e');
      return [];
    }
  }

  Future<Brand> getBrand(int id) async {
    final response = await _apiClient.get(
      '${AppConstants.brandsEndpoint}/$id',
    );
    return Brand.fromJson(response as Map<String, dynamic>);
  }

  Future<Brand> createBrand(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      AppConstants.brandsEndpoint,
      body: data,
    );
    return Brand.fromJson(response as Map<String, dynamic>);
  }

  Future<Brand> updateBrand(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '${AppConstants.brandsEndpoint}/$id',
      body: data,
    );
    return Brand.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteBrand(int id) async {
    await _apiClient.delete('${AppConstants.brandsEndpoint}/$id');
  }
}
