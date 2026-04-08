import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

enum ProductState { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  final ProductService _productService;

  ProductState _state = ProductState.initial;
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  Product? _selectedProduct;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  List<Map<String, dynamic>> _publicSpecifications = [];
  List<String> _productImages = [];

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
  Product? get selectedProduct => _selectedProduct;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  int? get selectedCategoryId => _selectedCategoryId;
  int? get selectedBrandId => _selectedBrandId;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  List<Map<String, dynamic>> get publicSpecifications => _publicSpecifications;
  List<String> get productImages => _productImages;

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
    try {
      _featuredProducts = await _productService.getFeaturedProducts();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadProduct(int id) async {
    _state = ProductState.loading;
    _productImages = [];
    notifyListeners();
    try {
      _selectedProduct = await _productService.getProduct(id);
      _state = ProductState.loaded;
      _errorMessage = null;
      // Load specs and images in parallel
      await Future.wait([
        loadPublicSpecifications(id),
        _loadProductImages(id),
      ]);
    } catch (e) {
      _state = ProductState.error;
      _errorMessage = e.toString();
      print('Error loading product $id: $e');
    }
    notifyListeners();
  }

  Future<void> _loadProductImages(int productId) async {
    try {
      _productImages = await _productService.getProductImages(productId);
      // Fall back to product.photo if no images returned
      if (_productImages.isEmpty && _selectedProduct?.imageUrl != null) {
        _productImages = [_selectedProduct!.imageUrl!];
      }
      notifyListeners();
    } catch (e) {
      print('Error loading product images: $e');
    }
  }

  Future<void> loadPublicSpecifications(int productId) async {
    try {
      _publicSpecifications =
          await _productService.getPublicSpecifications(productId);
      notifyListeners();
    } catch (e) {
      print('Error loading public specifications: $e');
    }
  }

  void setFilter({int? categoryId, int? brandId, String? sortBy}) {
    _selectedCategoryId = categoryId;
    _selectedBrandId = brandId;
    if (sortBy != null) _sortBy = sortBy;
    loadProducts(refresh: true);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    print('ProductProvider: setSearchQuery = "$query"');
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
