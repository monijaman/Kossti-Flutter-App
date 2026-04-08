import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/category_card.dart';
import '../../widgets/common/review_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/app_error_widget.dart';
import '../products/product_list_screen.dart';
import '../categories/categories_screen.dart';
import '../brands/brands_screen.dart';
import '../brands/brands_for_category_screen.dart';
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
            // Search bar
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

            // Categories grid — tap to see brands in that category
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
            const _CategoriesGrid(),
            const SizedBox(height: 24),

            // Latest Reviews
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

/// Full categories grid. Tapping a category navigates to BrandsForCategoryScreen.
class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale.languageCode;

    return Consumer<CategoryProvider>(
      builder: (_, cats, __) {
        if (cats.loading) {
          return const SizedBox(
            height: 120,
            child: Center(child: LoadingWidget()),
          );
        }
        if (cats.errorMessage != null && cats.categories.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppErrorWidget(
              message: cats.errorMessage!,
              onRetry: cats.loadCategories,
            ),
          );
        }
        if (cats.categories.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppStrings.noData,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: cats.categories.length,
            itemBuilder: (_, i) {
              final cat = cats.categories[i];
              return CategoryCard(
                category: cat,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BrandsForCategoryScreen(category: cat),
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
