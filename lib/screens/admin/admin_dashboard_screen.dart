import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/brand_provider.dart';
import '../../providers/review_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'admin_products_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_brands_screen.dart';
import 'admin_reviews_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(refresh: true);
      context.read<CategoryProvider>().loadCategories();
      context.read<BrandProvider>().loadBrands();
      context.read<ReviewProvider>().loadAllReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminDashboard),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.overview,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Stats grid
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              children: [
                Consumer<ProductProvider>(
                  builder: (_, p, __) => _StatCard(
                    title: AppStrings.totalProducts,
                    value: p.products.length.toString(),
                    icon: Icons.shopping_bag_outlined,
                    color: AppColors.primary,
                  ),
                ),
                Consumer<ReviewProvider>(
                  builder: (_, r, __) => _StatCard(
                    title: AppStrings.totalReviews,
                    value: r.reviews.length.toString(),
                    icon: Icons.rate_review_outlined,
                    color: AppColors.accent,
                  ),
                ),
                Consumer<BrandProvider>(
                  builder: (_, b, __) => _StatCard(
                    title: AppStrings.totalBrands,
                    value: b.brands.length.toString(),
                    icon: Icons.business_outlined,
                    color: AppColors.secondary,
                  ),
                ),
                Consumer<ReviewProvider>(
                  builder: (_, r, __) => _StatCard(
                    title: AppStrings.pendingReviews,
                    value: r.reviews
                        .where((rev) => rev.isPending)
                        .length
                        .toString(),
                    icon: Icons.pending_outlined,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.manage,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _ManageItem(
              icon: Icons.shopping_bag_outlined,
              title: AppStrings.manageProducts,
              color: AppColors.primary,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AdminProductsScreen()),
              ),
            ),
            _ManageItem(
              icon: Icons.grid_view_outlined,
              title: AppStrings.manageCategories,
              color: AppColors.accent,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AdminCategoriesScreen()),
              ),
            ),
            _ManageItem(
              icon: Icons.business_outlined,
              title: AppStrings.manageBrands,
              color: AppColors.secondary,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AdminBrandsScreen()),
              ),
            ),
            _ManageItem(
              icon: Icons.rate_review_outlined,
              title: AppStrings.manageReviews,
              color: AppColors.info,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AdminReviewsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ManageItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
