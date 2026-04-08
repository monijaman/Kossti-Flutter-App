import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/review.dart';

class ReviewService {
  final ApiClient _apiClient;

  ReviewService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<Review>> getProductReviews(int productId, {String locale = 'en'}) async {
    final response = await _apiClient.get(
      '${AppConstants.reviewsEndpoint}/$productId',
      queryParams: {'locale': locale},
    );
    print('API reviews response: $response');

    // API returns: {"count":1, "reviews": [{"review": {...}}]}
    // Unwrap the nested {review: {...}} structure
    List<dynamic> data = [];
    if (response is Map && response['reviews'] is List) {
      final list = response['reviews'] as List;
      data = list.map((item) {
        // Each item is {review: {...}} - unwrap it
        if (item is Map && item['review'] != null) return item['review'];
        return item;
      }).toList();
    } else if (response is List) {
      data = response;
    }

    return data.map((r) {
      try {
        return Review.fromJson(r as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing review: $e\nData: $r');
        return null;
      }
    }).whereType<Review>().toList();
  }

  Future<List<Review>> getAllReviews({String? status, int page = 1}) async {
    final params = <String, String>{
      'page': page.toString(),
      'pageSize': AppConstants.pageSize.toString(),
    };
    if (status != null) params['status'] = status;

    final response = await _apiClient.get(
      AppConstants.reviewsEndpoint,
      queryParams: params,
    );
    final List<dynamic> data =
        response['data'] ?? response as List<dynamic>;
    return data
        .map((r) => Review.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<Review> createReview(
      int productId, Map<String, dynamic> data) async {
    data['productId'] = productId;
    final response = await _apiClient.post(
      AppConstants.reviewsEndpoint,
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
