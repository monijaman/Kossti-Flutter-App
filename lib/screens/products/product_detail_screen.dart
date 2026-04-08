import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/review_card.dart';
import '../auth/login_screen.dart';

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

        final images = product.images.isNotEmpty
            ? product.images
            : (product.imageUrl != null ? [product.imageUrl!] : <String>[]);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.reviews,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Consumer<AuthProvider>(
                            builder: (_, auth, __) => TextButton.icon(
                              onPressed: () {
                                if (!auth.isAuthenticated) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => const LoginScreen()),
                                  );
                                  return;
                                }
                                _showAddReviewSheet(context);
                              },
                              icon: const Icon(Icons.rate_review_outlined,
                                  size: 18),
                              label: const Text(AppStrings.writeReview),
                            ),
                          ),
                        ],
                      ),
                      Consumer<ReviewProvider>(
                        builder: (_, reviewProvider, __) {
                          if (reviewProvider.loading) {
                            return const LoadingWidget();
                          }
                          if (reviewProvider.reviews.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                  child: Text(AppStrings.noReviews)),
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
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddReviewSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    double rating = 4.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Text(AppStrings.writeReview,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(AppStrings.yourRating),
                const SizedBox(height: 8),
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  itemSize: 36,
                  itemBuilder: (_, __) =>
                      const Icon(Icons.star, color: AppColors.star),
                  onRatingUpdate: (r) =>
                      setSheetState(() => rating = r),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.reviewTitle,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? AppStrings.titleRequired : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: bodyController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: AppStrings.reviewBody,
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? AppStrings.reviewRequired : null,
                ),
                const SizedBox(height: 20),
                Consumer<ReviewProvider>(
                  builder: (_, reviewProvider, __) =>
                      ElevatedButton(
                    onPressed: reviewProvider.submitting
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            final success =
                                await reviewProvider.submitReview(
                              widget.productId,
                              {
                                'title': titleController.text,
                                'body': bodyController.text,
                                'rating': rating,
                              },
                            );
                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      AppStrings.reviewSubmitted),
                                ),
                              );
                            }
                          },
                    child: reviewProvider.submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(AppStrings.submitReview),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
