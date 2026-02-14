import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/kindergarten_detail.dart';
import '../../../widgets/badge_chip.dart';

class DetailHeader extends StatelessWidget {
  final KindergartenDetail detail;

  const DetailHeader({super.key, required this.detail});

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _copyAddress(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: detail.address));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('주소가 복사되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _callPhone() async {
    final uri = Uri.parse('tel:${detail.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openHomepage() async {
    if (detail.homepage == null || detail.homepage!.isEmpty) return;
    var url = detail.homepage!;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BadgeChip.establishType(
            label: detail.establishType,
            establishType: detail.establishType,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: detail.address,
            trailing: IconButton(
              onPressed: () => _copyAddress(context),
              icon: const Icon(Icons.copy, size: 18, color: AppColors.gray500),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: '주소 복사',
            ),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.phone_outlined,
            text: detail.phone,
            trailing: IconButton(
              onPressed: _callPhone,
              icon: const Icon(Icons.call, size: 18, color: AppColors.primary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: '전화 걸기',
            ),
          ),
          if (detail.operatingHours != null &&
              detail.operatingHours!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.access_time_outlined,
              text: detail.operatingHours!,
            ),
          ],
          if (detail.homepage != null && detail.homepage!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.language_outlined,
              text: detail.homepage!,
              trailing: IconButton(
                onPressed: _openHomepage,
                icon: const Icon(
                  Icons.open_in_new,
                  size: 18,
                  color: AppColors.primary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: '홈페이지 열기',
              ),
            ),
          ],
          if (detail.directorName != null &&
              detail.directorName!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.person_outlined,
              text: '원장: ${detail.directorName}',
            ),
          ],
          if (detail.representativeName != null &&
              detail.representativeName!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.person_outline,
              text: '대표자: ${detail.representativeName}',
            ),
          ],
          if (detail.establishDate != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              text: '설립일: ${_formatDate(detail.establishDate)}',
            ),
          ],
          if (detail.openDate != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.event_outlined,
              text: '개원일: ${_formatDate(detail.openDate)}',
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.gray500),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body2.copyWith(color: AppColors.gray700),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
