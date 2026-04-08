import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/brand.dart';

class BrandService {
  final ApiClient _apiClient;

  BrandService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Brand>> getBrands({int? categoryId}) async {
    final params = <String, String>{};
    if (categoryId != null) params['category_id'] = categoryId.toString();
    final response = await _apiClient.get(
      AppConstants.brandsEndpoint,
      queryParams: params.isNotEmpty ? params : null,
    );
    return ApiClient.extractList(response)
        .map((b) => Brand.fromJson(b as Map<String, dynamic>))
        .toList();
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
