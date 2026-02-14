import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../../providers/kindergarten_providers.dart';
import '../../providers/location_providers.dart';
import '../../widgets/error_state.dart';
import '../../widgets/badge_chip.dart';

class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compareIds = ref.watch(compareIdsProvider);

    if (compareIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('비교'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.compare_arrows,
                size: 80,
                color: AppColors.gray400,
              ),
              SizedBox(height: 16),
              Text(
                '비교할 유치원을 선택해주세요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '즐겨찾기에서 2~4개 유치원을 선택하고\n비교하기 버튼을 눌러주세요',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.gray500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 현재 위치 가져오기
    final currentPositionAsync = ref.watch(currentPositionProvider);
    
    return currentPositionAsync.when(
      data: (position) {
        final compareParams = (
          ids: compareIds,
          lat: position?.latitude,
          lng: position?.longitude,
        );

        final compareResultAsync = ref.watch(compareResultProvider(compareParams));

        return compareResultAsync.when(
          data: (compareResponse) => _buildCompareContent(context, ref, compareResponse),
          loading: () => Scaffold(
            appBar: AppBar(title: const Text('비교')),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: const Text('비교')),
            body: ErrorState(
              message: error.toString(),
              onRetry: () => ref.invalidate(compareResultProvider(compareParams)),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('비교')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) {
        // 위치 없이도 비교 가능
        final compareParams = (
          ids: compareIds,
          lat: null,
          lng: null,
        );

        final compareResultAsync = ref.watch(compareResultProvider(compareParams));
        
        return compareResultAsync.when(
          data: (compareResponse) => _buildCompareContent(context, ref, compareResponse),
          loading: () => Scaffold(
            appBar: AppBar(title: const Text('비교')),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: const Text('비교')),
            body: ErrorState(
              message: error.toString(),
              onRetry: () => ref.invalidate(compareResultProvider(compareParams)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompareContent(BuildContext context, WidgetRef ref, compareResponse) {
    final items = compareResponse.centers;

    return Scaffold(
      appBar: AppBar(
        title: Text('유치원 비교 (${items.length}개)'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(compareIdsProvider.notifier).state = [];
              context.pop();
            },
            child: const Text('완료'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: AppDecorations.cardDecoration(),
              clipBehavior: Clip.antiAlias,
              child: _CompareTable(items: items),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompareTable extends StatelessWidget {
  final List<dynamic> items; // CompareItem 리스트

  const _CompareTable({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: AppColors.gray200),
      defaultColumnWidth: const FixedColumnWidth(120),
      children: [
        // 헤더 (유치원 이름들)
        TableRow(
          decoration: const BoxDecoration(color: AppColors.gray100),
          children: [
            const _TableCell('항목', isHeader: true),
            ...items.map(
              (item) => _TableCell(
                item.name,
                isHeader: true,
                onTap: () => context.push('/detail/${item.id}'),
              ),
            ),
          ],
        ),

        // 설립유형
        TableRow(
          children: [
            const _TableCell('설립유형'),
            ...items.map(
              (item) => _TableCell(
                item.establishType,
                child: BadgeChip.establishType(
                  label: item.establishType,
                  establishType: item.establishType,
                ),
              ),
            ),
          ],
        ),

        // 주소
        TableRow(
          children: [
            const _TableCell('주소'),
            ...items.map((item) => _TableCell(item.address)),
          ],
        ),

        // 거리
        TableRow(
          children: [
            const _TableCell('거리'),
            ...items.map((item) => _TableCell(item.formattedDistance)),
          ],
        ),

        // 정원/현원
        TableRow(
          children: [
            const _TableCell('정원'),
            ...items.map((item) => _TableCell('${item.capacity}명')),
          ],
        ),

        TableRow(
          children: [
            const _TableCell('현원'),
            ...items.map(
              (item) => _TableCell(
                '${item.currentEnrollment}명',
                textColor: _getOccupancyColor(item.occupancyRate),
              ),
            ),
          ],
        ),

        // 교사/학급 수
        TableRow(
          children: [
            const _TableCell('교사 수'),
            ...items.map((item) => _TableCell('${item.teacherCount}명')),
          ],
        ),

        TableRow(
          children: [
            const _TableCell('학급 수'),
            ...items.map((item) => _TableCell('${item.classCount}개')),
          ],
        ),

        // 서비스 (O/X)
        TableRow(
          children: [
            const _TableCell('급식'),
            ...items.map(
              (item) => _TableCell(
                '',
                child: Icon(
                  item.mealProvided ? Icons.check_circle : Icons.cancel,
                  color: item.mealProvided ? AppColors.success : AppColors.gray400,
                  size: 20,
                ),
              ),
            ),
          ],
        ),

        TableRow(
          children: [
            const _TableCell('통학버스'),
            ...items.map(
              (item) => _TableCell(
                '',
                child: Icon(
                  item.busAvailable ? Icons.check_circle : Icons.cancel,
                  color: item.busAvailable ? AppColors.success : AppColors.gray400,
                  size: 20,
                ),
              ),
            ),
          ],
        ),

        TableRow(
          children: [
            const _TableCell('연장돌봄'),
            ...items.map(
              (item) => _TableCell(
                '',
                child: Icon(
                  item.extendedCare ? Icons.check_circle : Icons.cancel,
                  color: item.extendedCare ? AppColors.success : AppColors.gray400,
                  size: 20,
                ),
              ),
            ),
          ],
        ),

        // 면적
        TableRow(
          children: [
            const _TableCell('건물면적'),
            ...items.map((item) => _TableCell('${item.buildingArea.toStringAsFixed(0)}㎡')),
          ],
        ),

        TableRow(
          children: [
            const _TableCell('교실면적'),
            ...items.map((item) => _TableCell('${item.classroomArea.toStringAsFixed(0)}㎡')),
          ],
        ),

        // CCTV
        TableRow(
          children: [
            const _TableCell('CCTV'),
            ...items.map((item) => _TableCell(item.cctvDisplayText)),
          ],
        ),
      ],
    );
  }

  Color _getOccupancyColor(double rate) {
    if (rate > 0.9) return AppColors.error;
    if (rate > 0.7) return AppColors.warning;
    return AppColors.success;
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final Widget? child;
  final Color? textColor;
  final VoidCallback? onTap;

  const _TableCell(
    this.text, {
    this.isHeader = false,
    this.child,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.all(8),
      child: child ?? Text(
        text,
        textAlign: TextAlign.center,
        style: isHeader 
            ? AppTextStyles.tableHeader
            : AppTextStyles.tableContent.copyWith(color: textColor),
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}