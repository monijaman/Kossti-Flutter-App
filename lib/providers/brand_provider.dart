import 'package:flutter/material.dart';
import '../models/brand.dart';
import '../services/brand_service.dart';

class BrandProvider extends ChangeNotifier {
  final BrandService _brandService;

  bool _loading = false;
  List<Brand> _brands = [];
  String? _errorMessage;

  BrandProvider({BrandService? brandService})
      : _brandService = brandService ?? BrandService();

  bool get loading => _loading;
  List<Brand> get brands => _brands;
  String? get errorMessage => _errorMessage;

  Future<void> loadBrands({int? categoryId}) async {
    _loading = true;
    notifyListeners();
    try {
      _brands = await _brandService.getBrands(categoryId: categoryId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> deleteBrand(int id) async {
    await _brandService.deleteBrand(id);
    _brands.removeWhere((b) => b.id == id);
    notifyListeners();
  }
}
