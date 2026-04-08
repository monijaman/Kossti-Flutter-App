import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/brand_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/app_error_widget.dart';
import '../products/product_list_screen.dart';

/// Shows brands that belong to the selected [category].
/// Tapping a brand navigates to [ProductListScreen] filtered by both that brand and the category.
class BrandsForCategoryScreen extends StatefulWidget {
  final Category category;

  const BrandsForCategoryScreen({super.key, required this.category});

  @override
  State<BrandsForCategoryScreen> createState() =>
      _BrandsForCategoryScreenState();
}

class _BrandsForCategoryScreenState extends State<BrandsForCategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<BrandProvider>()
          .loadBrands(categoryId: widget.category.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    final categoryName = widget.category.localizedName(locale);

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: Consumer<BrandProvider>(
        builder: (_, provider, __) {
          if (provider.loading) return const LoadingWidget();
          if (provider.errorMessage != null && provider.brands.isEmpty) {
            return AppErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.loadBrands(categoryId: widget.category.id),
            );
          }
          if (provider.brands.isEmpty) {
            return const Center(child: Text(AppStrings.noData));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: provider.brands.length,
            itemBuilder: (_, i) => BrandCard(
              brand: provider.brands[i],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductListScreen(
                    brandId: provider.brands[i].id,
                    categoryId: widget.category.id,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
