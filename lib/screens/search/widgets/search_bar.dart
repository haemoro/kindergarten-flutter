import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/search_filter.dart';
import '../../../providers/kindergarten_providers.dart';

class CustomSearchBar extends ConsumerStatefulWidget {
  const CustomSearchBar({super.key});

  @override
  ConsumerState<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends ConsumerState<CustomSearchBar> {
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    final initialFilter = ref.read(searchFilterProvider);
    if (initialFilter.q != null) {
      _controller.text = initialFilter.q!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {}); // Update clear button visibility
    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.searchDebounceTime, () {
      _applySearchQuery(query.isEmpty ? '' : query);
    });
  }

  void _onClear() {
    _controller.clear();
    _debounceTimer?.cancel();
    setState(() {});
    _applySearchQuery('');
  }

  void _applySearchQuery(String query) {
    final currentFilter = ref.read(searchFilterProvider);
    ref.read(searchFilterProvider.notifier).state = SearchFilter(
      q: query.isEmpty ? null : query,
      lat: currentFilter.lat,
      lng: currentFilter.lng,
      radiusKm: currentFilter.radiusKm,
      type: currentFilter.type,
      sidoCode: currentFilter.sidoCode,
      sggCode: currentFilter.sggCode,
      sort: currentFilter.sort,
    );
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        style: AppTextStyles.body1,
        decoration: InputDecoration(
          hintText: '유치원 이름이나 주소를 검색하세요',
          hintStyle: AppTextStyles.body2.copyWith(color: AppColors.gray500),
          prefixIcon: const Icon(Icons.search, color: AppColors.gray500),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  onPressed: _onClear,
                  icon: const Icon(Icons.clear, color: AppColors.gray400),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: surfaceColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}
