import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/category_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/app_error_widget.dart';
import '../brands/brands_for_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.allCategories)),
      body: Consumer<CategoryProvider>(
        builder: (_, provider, __) {
          if (provider.loading) return const LoadingWidget();
          if (provider.errorMessage != null && provider.categories.isEmpty) {
            return AppErrorWidget(
              message: provider.errorMessage!,
              onRetry: provider.loadCategories,
            );
          }
          if (provider.categories.isEmpty) {
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
            itemCount: provider.categories.length,
            itemBuilder: (_, i) => CategoryCard(
              category: provider.categories[i],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BrandsForCategoryScreen(
                    category: provider.categories[i],
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
