import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/review_card.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadAllReviews();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.manageReviews),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: AppStrings.tabAll),
            Tab(text: AppStrings.tabPending),
            Tab(text: AppStrings.tabApproved),
          ],
        ),
      ),
      body: Consumer<ReviewProvider>(
        builder: (_, provider, __) {
          if (provider.loading) return const LoadingWidget();
          return TabBarView(
            controller: _tabController,
            children: [
              _ReviewList(
                reviews: provider.reviews,
                provider: provider,
              ),
              _ReviewList(
                reviews:
                    provider.reviews.where((r) => r.isPending).toList(),
                provider: provider,
              ),
              _ReviewList(
                reviews:
                    provider.reviews.where((r) => r.isApproved).toList(),
                provider: provider,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  final List reviews;
  final ReviewProvider provider;

  const _ReviewList({required this.reviews, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(child: Text(AppStrings.noData));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (_, i) {
        final review = reviews[i];
        return ReviewCard(
          review: review,
          showActions: true,
          onApprove: () =>
              provider.updateReviewStatus(review.id, 'approved'),
          onReject: () =>
              provider.updateReviewStatus(review.id, 'rejected'),
          onDelete: () => provider.deleteReview(review.id),
        );
      },
    );
  }
}
