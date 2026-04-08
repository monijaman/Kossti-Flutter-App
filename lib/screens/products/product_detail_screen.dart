import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart' show RatingBarIndicator;
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/review_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProduct(widget.productId);
      context
          .read<ReviewProvider>()
          .loadProductReviews(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    final theme = Theme.of(context);

    return Consumer<ProductProvider>(
      builder: (_, productProvider, __) {
        if (productProvider.state == ProductState.loading &&
            productProvider.selectedProduct == null) {
          return const Scaffold(body: LoadingWidget());
        }
        if (productProvider.state == ProductState.error) {
          return Scaffold(
            appBar: AppBar(),
            body: AppErrorWidget(
              message: productProvider.errorMessage ?? AppStrings.error,
              onRetry: () =>
                  productProvider.loadProduct(widget.productId),
            ),
          );
        }
        final product = productProvider.selectedProduct;
        if (product == null) return const Scaffold(body: LoadingWidget());

        final images = productProvider.productImages.isNotEmpty
            ? productProvider.productImages
            : (product.imageUrl != null ? [product.imageUrl!] : <String>[]);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: images.isNotEmpty
                      ? PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (i) =>
                              setState(() => _selectedImageIndex = i),
                          itemBuilder: (_, i) => CachedNetworkImage(
                            imageUrl: images[i],
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.surfaceVariant,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.image_outlined,
                                  size: 60, color: AppColors.textHint),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.image_outlined,
                              size: 80, color: AppColors.textHint),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (images.length > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (i) => Container(
                              width: i == _selectedImageIndex ? 20 : 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: i == _selectedImageIndex
                                    ? AppColors.primary
                                    : AppColors.border,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (product.category != null)
                        Chip(
                          label: Text(
                              product.category!.localizedName(locale),
                              style: const TextStyle(fontSize: 12)),
                          backgroundColor: AppColors.primary.withAlpha(20),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        product.localizedName(locale),
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (product.brand != null)
                        Text(
                          product.brand!.localizedName(locale),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: product.averageRating,
                            itemSize: 20,
                            itemBuilder: (_, __) => const Icon(
                              Icons.star,
                              color: AppColors.star,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${product.averageRating.toStringAsFixed(1)} '
                            '(${product.reviewCount} reviews)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.description,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.localizedDescription(locale) ??
                            AppStrings.noDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Reviews and Specifications side-by-side layout
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 800;

                          if (isWide) {
                            // Side-by-side: Reviews (left) and Specs (right)
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Reviews (40%)
                                Expanded(
                                  flex: 2,
                                  child: _buildReviewsSection(context, theme),
                                ),
                                const SizedBox(width: 24),
                                // Specifications (60%)
                                Expanded(
                                  flex: 3,
                                  child: _buildSpecificationsSection(context, theme),
                                ),
                              ],
                            );
                          } else {
                            // Stacked: Reviews then Specs
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildReviewsSection(context, theme),
                                const SizedBox(height: 24),
                                _buildSpecificationsSection(context, theme),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.reviews,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Consumer<ReviewProvider>(
          builder: (_, reviewProvider, __) {
            if (reviewProvider.loading) {
              return const LoadingWidget();
            }
            if (reviewProvider.errorMessage != null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: ${reviewProvider.errorMessage}',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              );
            }
            if (reviewProvider.reviews.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text(AppStrings.noReviews)),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviewProvider.reviews.length,
              itemBuilder: (_, i) =>
                  ReviewCard(review: reviewProvider.reviews[i]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpecificationsSection(BuildContext context, ThemeData theme) {
    return Consumer<ProductProvider>(
      builder: (_, productProvider, __) {
        final specs = productProvider.publicSpecifications;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF3D3300),
                border: const Border(
                  left: BorderSide(color: Color(0xFFB8860B), width: 4),
                ),
              ),
              child: const Text(
                'Unofficial specifications',
                style: TextStyle(fontSize: 12, color: Color(0xFFD4A017)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Specifications',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (specs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No specifications available'),
              )
            else
              // 2 specs per row, matching crit_client layout
              Table(
                border: TableBorder.all(color: AppColors.border, width: 0.5),
                children: List.generate(
                  (specs.length / 2).ceil(),
                  (rowIndex) {
                    final left = specs[rowIndex * 2];
                    final right = rowIndex * 2 + 1 < specs.length
                        ? specs[rowIndex * 2 + 1]
                        : null;
                    return TableRow(
                      children: [
                        _specCell(
                          left['translated_key'] ?? '',
                          left['translated_value'] ?? '',
                          isAlt: false,
                        ),
                        _specCell(
                          right?['translated_key'] ?? '',
                          right?['translated_value'] ?? '',
                          isAlt: true,
                          isEmpty: right == null,
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _specCell(String key, String value,
      {bool isAlt = false, bool isEmpty = false}) {
    return Container(
      color: isAlt
          ? const Color(0xFF1A1A2E).withAlpha(30)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: isEmpty
          ? const SizedBox.shrink()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: Text(
                    key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
    );
  }
}
