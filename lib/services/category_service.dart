import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/category.dart';

class CategoryService {
  final ApiClient _apiClient;

  CategoryService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<Category>> getCategories() async {
    final response =
        await _apiClient.get(AppConstants.categoriesEndpoint);
    final List<dynamic> data =
        response['data'] ?? response as List<dynamic>;
    return data
        .map((c) => Category.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<Category> getCategory(int id) async {
    final response = await _apiClient.get(
      '${AppConstants.categoriesEndpoint}/$id',
    );
    return Category.fromJson(response as Map<String, dynamic>);
  }

  Future<Category> createCategory(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      AppConstants.categoriesEndpoint,
      body: data,
    );
    return Category.fromJson(response as Map<String, dynamic>);
  }

  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '${AppConstants.categoriesEndpoint}/$id',
      body: data,
    );
    return Category.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteCategory(int id) async {
    await _apiClient.delete('${AppConstants.categoriesEndpoint}/$id');
  }
}
