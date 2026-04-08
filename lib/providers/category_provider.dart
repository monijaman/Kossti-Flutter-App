import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService;

  bool _loading = false;
  List<Category> _categories = [];
  String? _errorMessage;

  CategoryProvider({CategoryService? categoryService})
      : _categoryService = categoryService ?? CategoryService();

  bool get loading => _loading;
  List<Category> get categories => _categories;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<void> loadCategories() async {
    _loading = true;
    notifyListeners();
    try {
      _categories = (await _categoryService.getCategories())
          .where((c) => c.isActive)
          .toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error loading categories: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> deleteCategory(int id) async {
    await _categoryService.deleteCategory(id);
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
