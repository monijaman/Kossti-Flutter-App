import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService;

  bool _loading = false;
  List<Review> _reviews = [];
  String? _errorMessage;
  bool _submitting = false;

  ReviewProvider({ReviewService? reviewService})
      : _reviewService = reviewService ?? ReviewService();

  bool get loading => _loading;
  List<Review> get reviews => _reviews;
  String? get errorMessage => _errorMessage;
  bool get submitting => _submitting;

  Future<void> loadProductReviews(int productId) async {
    _loading = true;
    _reviews = [];
    _errorMessage = null;
    notifyListeners();
    try {
      _reviews = await _reviewService.getProductReviews(productId);
    } catch (e) {
      _errorMessage = e.toString();
      print('ReviewProvider error: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadAllReviews({String? status}) async {
    _loading = true;
    notifyListeners();
    try {
      _reviews = await _reviewService.getAllReviews(status: status);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> submitReview(
      int productId, Map<String, dynamic> data) async {
    _submitting = true;
    notifyListeners();
    try {
      final review = await _reviewService.createReview(productId, data);
      _reviews.insert(0, review);
      _submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _submitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateReviewStatus(int reviewId, String status) async {
    final review = await _reviewService.updateReviewStatus(reviewId, status);
    final idx = _reviews.indexWhere((r) => r.id == reviewId);
    if (idx != -1) {
      _reviews[idx] = review;
      notifyListeners();
    }
  }

  Future<void> deleteReview(int reviewId) async {
    await _reviewService.deleteReview(reviewId);
    _reviews.removeWhere((r) => r.id == reviewId);
    notifyListeners();
  }
}
