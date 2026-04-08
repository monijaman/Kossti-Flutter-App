import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/brand.dart';
import '../../providers/locale_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';

class BrandCard extends StatelessWidget {
  final Brand brand;
  final VoidCallback? onTap;

  const BrandCard({super.key, required this.brand, this.onTap});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (brand.logoUrl != null)
              CachedNetworkImage(
                imageUrl: brand.logoUrl!,
                width: 60,
                height: 40,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.business_outlined,
                        size: 36, color: AppColors.textSecondary),
              )
            else
              const Icon(Icons.business_outlined,
                  size: 36, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(
              brand.localizedName(locale),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (brand.productCount > 0)
              Text(
                '${brand.productCount} ${AppStrings.productsCount}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
