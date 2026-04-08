import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/review.dart';

class ReviewService {
  final ApiClient _apiClient;

  ReviewService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<Review>> getProductReviews(int productId, {int page = 1}) async {
    final response = await _apiClient.get(
      '${AppConstants.productsEndpoint}/$productId${AppConstants.reviewsEndpoint}',
      queryParams: {
        'page': page.toString(),
        'per_page': AppConstants.pageSize.toString(),
      },
    );
    return ApiClient.extractList(response)
        .map((r) => Review.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<Review>> getAllReviews({String? status, int page = 1}) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': AppConstants.pageSize.toString(),
    };
    if (status != null) params['status'] = status;

    final response = await _apiClient.get(
      AppConstants.reviewsEndpoint,
      queryParams: params,
    );
    return ApiClient.extractList(response)
        .map((r) => Review.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<Review>> getLatestReviews({int limit = 5}) async {
    final response = await _apiClient.get(
      AppConstants.reviewsEndpoint,
      queryParams: {
        'page': '1',
        'per_page': limit.toString(),
        'status': 'approved',
        'sort_by': 'newest',
      },
    );
    return ApiClient.extractList(response)
        .map((r) => Review.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<Review> createReview(
      int productId, Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      '${AppConstants.productsEndpoint}/$productId${AppConstants.reviewsEndpoint}',
      body: data,
    );
    return Review.fromJson(response as Map<String, dynamic>);
  }

  Future<Review> updateReviewStatus(int reviewId, String status) async {
    final response = await _apiClient.put(
      '${AppConstants.reviewsEndpoint}/$reviewId',
      body: {'status': status},
    );
    return Review.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteReview(int reviewId) async {
    await _apiClient.delete('${AppConstants.reviewsEndpoint}/$reviewId');
  }
}
