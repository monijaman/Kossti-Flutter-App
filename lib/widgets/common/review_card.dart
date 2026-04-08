import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/review.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final bool showActions;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    this.showActions = false,
    this.onApprove,
    this.onReject,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withAlpha(30),
                  child: Text(
                    review.author?.name.isNotEmpty == true
                        ? review.author!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.author?.name ?? 'Anonymous',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        review.createdAt != null
                            ? _formatDate(review.createdAt!)
                            : '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                RatingBarIndicator(
                  rating: review.rating,
                  itemSize: 16,
                  itemBuilder: (_, __) =>
                      const Icon(Icons.star, color: AppColors.star),
                ),
              ],
            ),
            if (review.title.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                review.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              review.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (showActions) ...[
              const SizedBox(height: 12),
              const Divider(),
              Row(
                children: [
                  _statusChip(context),
                  const Spacer(),
                  if (review.isPending) ...[
                    TextButton(
                      onPressed: onApprove,
                      child: const Text(AppStrings.approveReview,
                          style: TextStyle(color: AppColors.success)),
                    ),
                    TextButton(
                      onPressed: onReject,
                      child: const Text(AppStrings.rejectReview,
                          style: TextStyle(color: AppColors.warning)),
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context) {
    Color color;
    String label;
    switch (review.status) {
      case 'approved':
        color = AppColors.success;
        label = AppStrings.tabApproved;
        break;
      case 'rejected':
        color = AppColors.error;
        label = AppStrings.rejectReview;
        break;
      default:
        color = AppColors.warning;
        label = AppStrings.tabPending;
    }
    return Chip(
      label: Text(label,
          style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withAlpha(20),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
