import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../../models/kindergarten_detail.dart';
import '../../providers/kindergarten_providers.dart';
import '../../providers/favorite_providers.dart';
import '../../providers/location_providers.dart';
import '../../widgets/error_state.dart';
import '../../widgets/badge_chip.dart';
import 'widgets/education_tab.dart';
import 'widgets/meal_tab.dart';
import 'widgets/safety_tab.dart';
import 'widgets/facility_tab.dart';
import 'widgets/teacher_tab.dart';
import 'widgets/after_school_tab.dart';

class DetailScreen extends ConsumerWidget {
  final String id;

  const DetailScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kindergartenAsync = ref.watch(kindergartenDetailProvider(id));

    return kindergartenAsync.when(
      data: (kindergarten) => DefaultTabController(
        length: 6,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // Gradient hero header
                SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () => _shareKindergarten(kindergarten),
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final isFavorite = ref.watch(isFavoriteProvider(id));

                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? AppColors.favoriteActive : Colors.white,
                          ),
                          onPressed: () async {
                            final success = await ref.read(favoritesProvider.notifier).toggle(id);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? (isFavorite ? '즐겨찾기에서 제거되었습니다' : '즐겨찾기에 추가되었습니다')
                                        : '즐겨찾기 처리에 실패했습니다',
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: AppDecorations.headerDecoration(),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 40, 20, 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      kindergarten.name,
                                      style: AppTextStyles.headline5.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  BadgeChip.establishType(
                                    label: kindergarten.establishType,
                                    establishType: kindergarten.establishType,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      kindergarten.address,
                                      style: AppTextStyles.body2.copyWith(color: Colors.white70),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Info section
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.background,
                    child: Container(
                      decoration: AppDecorations.cardDecoration(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 전화번호
                          if (kindergarten.phone.isNotEmpty)
                            _InfoRow(
                              icon: Icons.phone,
                              label: '전화',
                              value: kindergarten.phone,
                              onTap: () => _launchPhone(kindergarten.phone),
                            ),

                          // 운영시간
                          if (kindergarten.operatingHours != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.access_time,
                              label: '운영시간',
                              value: kindergarten.operatingHours!,
                            ),
                          ],

                          // 홈페이지
                          if (kindergarten.homepage != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.web,
                              label: '홈페이지',
                              value: kindergarten.homepage!,
                              onTap: () => _launchUrl(kindergarten.homepage!),
                            ),
                          ],

                          // 원장/대표
                          if (kindergarten.directorName != null || kindergarten.representativeName != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.person,
                              label: '원장',
                              value: kindergarten.directorName ?? kindergarten.representativeName ?? '',
                            ),
                          ],

                          // 설립일/개원일
                          if (kindergarten.establishDate != null || kindergarten.openDate != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: '개원일',
                              value: _formatDate(kindergarten.openDate ?? kindergarten.establishDate!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Pill TabBar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    child: Container(
                      color: AppColors.background,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TabBar(
                          isScrollable: true,
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.gray600,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          labelStyle: AppTextStyles.chipText.copyWith(fontWeight: FontWeight.w600),
                          unselectedLabelStyle: AppTextStyles.chipText,
                          tabAlignment: TabAlignment.start,
                          tabs: const [
                            Tab(text: '교육'),
                            Tab(text: '급식'),
                            Tab(text: '안전'),
                            Tab(text: '시설'),
                            Tab(text: '교사'),
                            Tab(text: '방과후'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                EducationTab(education: kindergarten.education),
                MealTab(meal: kindergarten.meal),
                SafetyTab(safety: kindergarten.safety),
                FacilityTab(facility: kindergarten.facility),
                TeacherTab(teacher: kindergarten.teacher),
                AfterSchoolTab(afterSchool: kindergarten.afterSchool),
              ],
            ),
          ),

          // Gradient bottom button
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '데이터 기준일: ${_formatDate(kindergarten.sourceUpdatedAt)}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      ref.read(mapFocusLocationProvider.notifier).state =
                          (lat: kindergarten.lat, lng: kindergarten.lng);
                      context.go('/map');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: AppDecorations.gradientButtonDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '지도에서 보기',
                            style: AppTextStyles.button.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('로딩 중...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('오류'),
        ),
        body: ErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(kindergartenDetailProvider(id));
          },
        ),
      ),
    );
  }

  void _shareKindergarten(KindergartenDetail kindergarten) {
    final buffer = StringBuffer();
    buffer.writeln('[${kindergarten.establishType}] ${kindergarten.name}');
    buffer.writeln(kindergarten.address);
    if (kindergarten.phone.isNotEmpty) {
      buffer.writeln('TEL: ${kindergarten.phone}');
    }
    if (kindergarten.homepage != null) {
      buffer.writeln(kindergarten.homepage);
    }
    buffer.writeln('\n- 유치원 찾기 앱에서 공유');
    Share.share(buffer.toString(), subject: kindergarten.name);
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate({required this.child});

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.gray600,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.gray600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body2,
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.chevron_right,
            size: 16,
            color: AppColors.gray400,
          ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: child,
        ),
      );
    }

    return child;
  }
}
