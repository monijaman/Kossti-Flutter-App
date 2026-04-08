import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/brand_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/product_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/app_error_widget.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final int? categoryId;
  final int? brandId;
  final String? initialSearch;

  const ProductListScreen({
    super.key,
    this.categoryId,
    this.brandId,
    this.initialSearch,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      provider.setFilter(
        categoryId: widget.categoryId,
        brandId: widget.brandId,
        sortBy: _sortBy,
      );
      if (widget.initialSearch != null) {
        _searchController.text = widget.initialSearch!;
        provider.setSearchQuery(widget.initialSearch!);
      }
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductProvider>().loadProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.products),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: AppStrings.searchHint,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (q) {
                context.read<ProductProvider>().setSearchQuery(q);
              },
            ),
          ),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (_, provider, __) {
                if (provider.products.isEmpty &&
                    provider.state == ProductState.loading) {
                  return const LoadingWidget();
                }
                if (provider.state == ProductState.error &&
                    provider.products.isEmpty) {
                  return AppErrorWidget(
                    message: provider.errorMessage ?? AppStrings.error,
                    onRetry: () => provider.loadProducts(refresh: true),
                  );
                }
                if (provider.products.isEmpty) {
                  return const Center(child: Text(AppStrings.noData));
                }
                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: provider.products.length +
                      (provider.hasMore ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == provider.products.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final p = provider.products[i];
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    final cats = context.read<CategoryProvider>().categories;
    final brands = context.read<BrandProvider>().brands;
    int? selectedCategory = context.read<ProductProvider>().selectedCategoryId;
    int? selectedBrand = context.read<ProductProvider>().selectedBrandId;
    String sortBy = context.read<ProductProvider>().sortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollCtrl) => SingleChildScrollView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(AppStrings.filterBy,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(AppStrings.sortBy,
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['newest', 'top_rated', 'price_asc', 'price_desc']
                      .map((s) {
                        final label = switch (s) {
                          'newest' => AppStrings.sortNewest,
                          'top_rated' => AppStrings.sortTopRated,
                          'price_asc' => AppStrings.sortPriceAsc,
                          'price_desc' => AppStrings.sortPriceDesc,
                          _ => s,
                        };
                        return ChoiceChip(
                          label: Text(label),
                          selected: sortBy == s,
                          onSelected: (_) => setSheetState(() => sortBy = s),
                        );
                      }).toList(),
                ),
                if (cats.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(AppStrings.categories,
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: cats
                        .map((c) => ChoiceChip(
                              label: Text(c.name),
                              selected: selectedCategory == c.id,
                              onSelected: (_) => setSheetState(() {
                                selectedCategory =
                                    selectedCategory == c.id ? null : c.id;
                              }),
                            ))
                        .toList(),
                  ),
                ],
                if (brands.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(AppStrings.brands,
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: brands
                        .map((b) => ChoiceChip(
                              label: Text(b.name),
                              selected: selectedBrand == b.id,
                              onSelected: (_) => setSheetState(() {
                                selectedBrand =
                                    selectedBrand == b.id ? null : b.id;
                              }),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProductProvider>().setFilter(
                          categoryId: selectedCategory,
                          brandId: selectedBrand,
                          sortBy: sortBy,
                        );
                    Navigator.pop(ctx);
                  },
                  child: const Text(AppStrings.applyFilters),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    context.read<ProductProvider>().clearFilters();
                    Navigator.pop(ctx);
                  },
                  child: const Text(AppStrings.clearFilters),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
