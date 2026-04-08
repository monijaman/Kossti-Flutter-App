import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/product.dart';
import '../services/product_service.dart';

enum ProductState { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  final ProductService _productService;

  ProductState _state = ProductState.initial;
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _popularProducts = [];
  bool _featuredLoading = false;
  bool _popularLoading = false;
  int _popularPage = 1;
  bool _popularHasMore = true;
  Product? _selectedProduct;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  // Filters
  int? _selectedCategoryId;
  int? _selectedBrandId;
  String _searchQuery = '';
  String _sortBy = 'newest';

  ProductProvider({ProductService? productService})
      : _productService = productService ?? ProductService();

  ProductState get state => _state;
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get popularProducts => _popularProducts;
  Product? get selectedProduct => _selectedProduct;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get featuredLoading => _featuredLoading;
  bool get popularLoading => _popularLoading;
  bool get popularHasMore => _popularHasMore;
  int? get selectedCategoryId => _selectedCategoryId;
  int? get selectedBrandId => _selectedBrandId;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _products = [];
    }
    if (!_hasMore) return;
    if (_state == ProductState.loading) return;

    _state = ProductState.loading;
    notifyListeners();
    try {
      final fetched = await _productService.getProducts(
        page: _currentPage,
        categoryId: _selectedCategoryId,
        brandId: _selectedBrandId,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        sortBy: _sortBy,
      );
      if (refresh) {
        _products = fetched;
      } else {
        _products.addAll(fetched);
      }
      _hasMore = fetched.length >= 20;
      _currentPage++;
      _state = ProductState.loaded;
    } catch (e) {
      _state = ProductState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadFeaturedProducts() async {
    _featuredLoading = true;
    notifyListeners();
    try {
      _featuredProducts = await _productService.getFeaturedProducts();
    } catch (_) {
      _featuredProducts = [];
    }
    _featuredLoading = false;
    notifyListeners();
  }

  Future<void> loadPopularProducts({bool refresh = false}) async {
    if (refresh) {
      _popularPage = 1;
      _popularHasMore = true;
      _popularProducts = [];
    }
    if (!_popularHasMore) return;
    if (_popularLoading) return;

    _popularLoading = true;
    notifyListeners();
    try {
      final fetched = await _productService.getProducts(
        page: _popularPage,
        sortBy: 'top_rated',
      );
      _popularProducts.addAll(fetched);
      _popularHasMore = fetched.length >= AppConstants.pageSize;
      _popularPage++;
    } catch (e) {
      _errorMessage = e.toString();
      _popularHasMore = false;
    }
    _popularLoading = false;
    notifyListeners();
  }

  Future<void> loadProduct(int id) async {
    _state = ProductState.loading;
    notifyListeners();
    try {
      _selectedProduct = await _productService.getProduct(id);
      _state = ProductState.loaded;
    } catch (e) {
      _state = ProductState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void setFilter({int? categoryId, int? brandId, String? sortBy}) {
    _selectedCategoryId = categoryId;
    _selectedBrandId = brandId;
    if (sortBy != null) _sortBy = sortBy;
    loadProducts(refresh: true);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadProducts(refresh: true);
  }

  void clearFilters() {
    _selectedCategoryId = null;
    _selectedBrandId = null;
    _searchQuery = '';
    _sortBy = 'newest';
    loadProducts(refresh: true);
  }

  Future<void> deleteProduct(int id) async {
    await _productService.deleteProduct(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
