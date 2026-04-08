import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/product_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../services/brand_service.dart';
import '../../models/brand.dart';
import '../products/product_list_screen.dart';
import '../products/product_detail_screen.dart';
import '../categories/categories_screen.dart';
import '../brands/brands_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadFeaturedProducts();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  final List<Widget> _screens = [
    const _HomeTab(),
    const ProductListScreen(),
    const CategoriesScreen(),
    const BrandsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: AppStrings.products,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: AppStrings.categories,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: AppStrings.brands,
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  int? _selectedCategoryId;
  String? _selectedCategorySlug;
  String? _selectedCategoryName;
  List<Brand> _categoryBrands = [];
  bool _brandsLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) return;
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted && query.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductListScreen(initialSearch: query),
          ),
        ).then((_) => _searchController.clear());
      }
    });
  }

  Future<void> _onCategorySelected(int id, String slug, String name) async {
    setState(() {
      _selectedCategoryId = id;
      _selectedCategorySlug = slug;
      _selectedCategoryName = name;
      _categoryBrands = [];
      _brandsLoading = true;
    });
    final brands = await BrandService().getCategoryBrands(slug);
    if (mounted) {
      setState(() {
        _categoryBrands = brands;
        _brandsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/images/kossti.svg',
          height: 32,
        ),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AdminDashboardScreen()),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onSubmitted: (q) {
                  _debounce?.cancel();
                  if (q.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductListScreen(initialSearch: q),
                      ),
                    ).then((_) => _searchController.clear());
                  }
                },
                decoration: const InputDecoration(
                  hintText: AppStrings.searchHint,
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Featured Products
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.featuredProducts,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProductListScreen()),
                  ),
                  child: const Text(AppStrings.seeAll),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Consumer<ProductProvider>(
              builder: (_, products, __) {
                if (products.errorMessage != null) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error: ${products.errorMessage}',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
                    ),
                  );
                }
                if (products.featuredProducts.isEmpty) {
                  return const LoadingWidget();
                }
                return SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.featuredProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final p = products.featuredProducts[i];
                      return SizedBox(
                        width: 160,
                        child: ProductCard(
                          product: p,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(productId: p.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.allCategories,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                  ),
                  child: const Text(AppStrings.seeAll),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Consumer<CategoryProvider>(
              builder: (_, cats, __) {
                if (cats.loading) return const LoadingWidget();
                if (cats.categories.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: cats.categories.map((cat) {
                    final isSelected = _selectedCategoryId == cat.id;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _onCategorySelected(cat.id, cat.slug, cat.name),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withAlpha(30)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: AppColors.primary.withAlpha(80))
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cat.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected ? AppColors.primary : null,
                                  ),
                                ),
                                if (cat.productCount > 0)
                                  Text(
                                    '${cat.productCount}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // Show brands under selected category
                        if (isSelected) ...[
                          const SizedBox(height: 8),
                          if (_brandsLoading)
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          else if (_categoryBrands.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Text(
                                'No brands in this category',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(left: 12, bottom: 4),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _categoryBrands.map((brand) {
                                  return ActionChip(
                                    label: Text(brand.name),
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProductListScreen(
                                          categoryId: _selectedCategoryId,
                                          brandId: brand.id,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          const SizedBox(height: 4),
                        ],
                        const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
