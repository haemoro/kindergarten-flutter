import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/kindergarten_providers.dart';
import '../../providers/favorite_providers.dart';
import '../../providers/theme_provider.dart';

// 설정 Provider
final defaultRadiusProvider = StateProvider<double>((ref) => AppConstants.defaultRadius);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultRadius = ref.watch(defaultRadiusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // 검색 설정
          _buildSectionHeader('검색 설정'),

          // 기본 검색 반경 - SegmentedButton
          Container(
            decoration: AppDecorations.cardDecoration(
              color: Theme.of(context).cardTheme.color,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_searching, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('기본 검색 반경', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<double>(
                    segments: AppConstants.radiusOptions.map(
                      (radius) => ButtonSegment<double>(
                        value: radius,
                        label: Text('${radius.toInt()}km'),
                      ),
                    ).toList(),
                    selected: {defaultRadius},
                    onSelectionChanged: (selected) {
                      final value = selected.first;
                      ref.read(defaultRadiusProvider.notifier).state = value;
                      _saveRadiusSetting(value);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => states.contains(WidgetState.selected)
                            ? AppColors.primary
                            : Colors.transparent,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => states.contains(WidgetState.selected)
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 화면 설정
          _buildSectionHeader('화면 설정'),

          Container(
            decoration: AppDecorations.cardDecoration(
              color: Theme.of(context).cardTheme.color,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.dark_mode_outlined, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('테마 모드', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('시스템'),
                        icon: Icon(Icons.settings_suggest, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('라이트'),
                        icon: Icon(Icons.light_mode, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('다크'),
                        icon: Icon(Icons.dark_mode, size: 18),
                      ),
                    ],
                    selected: {ref.watch(themeModeProvider)},
                    onSelectionChanged: (selected) {
                      ref.read(themeModeProvider.notifier).setThemeMode(selected.first);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => states.contains(WidgetState.selected)
                            ? AppColors.primary
                            : Colors.transparent,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => states.contains(WidgetState.selected)
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 앱 정보
          _buildSectionHeader('앱 정보'),

          Container(
            decoration: AppDecorations.cardDecoration(
              color: Theme.of(context).cardTheme.color,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.primary),
                  title: const Text('앱 버전'),
                  subtitle: const Text('1.0.0+1'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.gray400),
                  onTap: () => _showVersionDialog(context),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.description, color: AppColors.primary),
                  title: const Text('오픈소스 라이선스'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.gray400),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: '유치원 찾기',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(
                      Icons.school,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 데이터 관리
          _buildSectionHeader('데이터 관리'),

          Container(
            decoration: AppDecorations.cardDecoration(
              color: Theme.of(context).cardTheme.color,
            ),
            child: ListTile(
              leading: const Icon(Icons.refresh, color: AppColors.warning),
              title: const Text('캐시 초기화'),
              subtitle: const Text('저장된 검색 결과와 즐겨찾기 캐시를 삭제합니다'),
              trailing: const Icon(Icons.chevron_right, color: AppColors.gray400),
              onTap: () => _showClearCacheDialog(context, ref),
            ),
          ),

          const SizedBox(height: 24),

          // 개발자 정보
          _buildSectionHeader('개발자'),

          Container(
            decoration: AppDecorations.cardDecoration(
              color: Theme.of(context).cardTheme.color,
            ),
            child: ListTile(
              leading: const Icon(Icons.developer_mode, color: AppColors.gray600),
              title: const Text('개발자 정보'),
              subtitle: const Text('유치원 찾기 앱 v1.0.0'),
              onTap: () => _showDeveloperDialog(context),
            ),
          ),

          // 하단 여백
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12, left: 4),
      child: Text(
        title,
        style: AppTextStyles.sectionTitle.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Future<void> _saveRadiusSetting(double radius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('default_radius', radius);
  }

  Future<void> _showVersionDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('유치원 찾기'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('버전: 1.0.0+1'),
            SizedBox(height: 8),
            Text('빌드: 2026.02.07'),
            SizedBox(height: 8),
            Text('Flutter MVP 버전'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearCacheDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐시 초기화'),
        content: const Text(
          '저장된 검색 결과와 즐겨찾기 캐시가 삭제됩니다.\n'
          '계속하시겠습니까?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.invalidate(kindergartenSearchProvider);
      ref.invalidate(favoritesProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('캐시가 초기화되었습니다')),
      );
    }
  }

  Future<void> _showDeveloperDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개발자 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('유치원 찾기 앱'),
            SizedBox(height: 8),
            Text('Flutter + Spring Boot 기반'),
            SizedBox(height: 8),
            Text('실제 공공데이터 활용'),
            SizedBox(height: 8),
            Text('MVP 버전 2026.02'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
