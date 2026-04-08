import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/product_card.dart';
import '../../widgets/common/review_card.dart';
import '../../widgets/common/loading_widget.dart';
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
      context.read<ProductProvider>().loadPopularProducts(refresh: true);
      context.read<CategoryProvider>().loadCategories();
      context.read<ReviewProvider>().loadLatestReviews();
    });
  }

  final List<Widget> _screens = const [
    _HomeTab(),
    ProductListScreen(),
    CategoriesScreen(),
    BrandsScreen(),
    ProfileScreen(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Categories horizontal scroll
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionHeader(
                title: AppStrings.allCategories,
                onSeeAll: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const _CategoriesRow(),
            const SizedBox(height: 20),

            // 2. Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onSubmitted: (q) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductListScreen(initialSearch: q),
                      ),
                    );
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
            ),
            const SizedBox(height: 24),

            // 3. Popular Products with pagination
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionHeader(
                title: AppStrings.popularProducts,
                onSeeAll: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProductListScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const _PopularProductsGrid(),
            const SizedBox(height: 24),

            // 4. Latest Reviews
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppStrings.latestReviews,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const _LatestReviewsList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
              theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text(AppStrings.seeAll),
          ),
      ],
    );
  }
}

/// Horizontal scroll row of category chips
class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale.languageCode;

    return Consumer<CategoryProvider>(
      builder: (_, cats, __) {
        if (cats.loading) {
          return const SizedBox(
            height: 40,
            child: Center(child: LoadingWidget()),
          );
        }
        if (cats.categories.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppStrings.noData,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: cats.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = cats.categories[i];
              return ActionChip(
                label: Text(cat.localizedName(locale)),
                avatar: const Icon(Icons.category_outlined, size: 16),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductListScreen(categoryId: cat.id),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Popular products grid with "Load More" pagination
class _PopularProductsGrid extends StatelessWidget {
  const _PopularProductsGrid();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (_, products, __) {
        if (products.popularLoading && products.popularProducts.isEmpty) {
          return const LoadingWidget();
        }
        if (products.popularProducts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  AppStrings.noData,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount: products.popularProducts.length,
                itemBuilder: (_, i) {
                  final p = products.popularProducts[i];
                  return ProductCard(
                    product: p,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailScreen(productId: p.id),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (products.popularHasMore) ...[
              const SizedBox(height: 12),
              products.popularLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () =>
                              context.read<ProductProvider>().loadPopularProducts(),
                          child: const Text(AppStrings.loadMore),
                        ),
                      ),
                    ),
            ],
          ],
        );
      },
    );
  }
}

/// Latest reviews list
class _LatestReviewsList extends StatelessWidget {
  const _LatestReviewsList();

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (_, reviews, __) {
        if (reviews.latestLoading) {
          return const LoadingWidget();
        }
        if (reviews.latestReviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  AppStrings.noReviews,
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.latestReviews.length,
          itemBuilder: (_, i) =>
              ReviewCard(review: reviews.latestReviews[i]),
        );
      },
    );
  }
}
