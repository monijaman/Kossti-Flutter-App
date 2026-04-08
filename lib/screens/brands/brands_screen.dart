import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/brand_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/app_error_widget.dart';
import '../products/product_list_screen.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandProvider>().loadBrands();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.allBrands)),
      body: Consumer<BrandProvider>(
        builder: (_, provider, __) {
          if (provider.loading) return const LoadingWidget();
          if (provider.errorMessage != null && provider.brands.isEmpty) {
            return AppErrorWidget(
              message: provider.errorMessage!,
              onRetry: provider.loadBrands,
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
                  builder: (_) =>
                      ProductListScreen(brandId: provider.brands[i].id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
