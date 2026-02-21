import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/center_review.dart';
import '../../../providers/kindergarten_providers.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';

class ReviewTab extends ConsumerWidget {
  final String kindergartenId;

  const ReviewTab({
    super.key,
    required this.kindergartenId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(kindergartenReviewsProvider(kindergartenId));

    return reviewsAsync.when(
      data: (pageResponse) {
        if (pageResponse.isEmpty) {
          return const EmptyState(
            title: '등록된 리뷰가 없습니다',
            subtitle: '블로그나 카페에 작성된 리뷰가 아직 수집되지 않았습니다',
            icon: Icons.rate_review_outlined,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: pageResponse.content.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _ReviewCard(review: pageResponse.content[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorState(
        message: '리뷰를 불러올 수 없습니다',
        onRetry: () => ref.invalidate(kindergartenReviewsProvider(kindergartenId)),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final CenterReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source badge + date
          Row(
            children: [
              _buildSourceBadge(),
              const Spacer(),
              if (review.postDate != null)
                Text(
                  formatDate(review.postDate!),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            review.title,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Snippet
          Text(
            review.snippet,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.gray600,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Link button
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _openLink(review.link),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_new,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '원문 보기',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceBadge() {
    final isBlog = review.isBlog;
    final color = isBlog ? AppColors.info : AppColors.success;
    final icon = isBlog ? Icons.article : Icons.forum;
    final label = isBlog ? '블로그' : '카페';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
