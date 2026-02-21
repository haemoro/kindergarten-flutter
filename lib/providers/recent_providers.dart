import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _recentViewedKey = 'recent_viewed_kindergartens';
const _maxRecentItems = 20;

class RecentItem {
  final String id;
  final String name;
  final DateTime viewedAt;

  const RecentItem({
    required this.id,
    required this.name,
    required this.viewedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'viewedAt': viewedAt.toIso8601String(),
      };

  factory RecentItem.fromJson(Map<String, dynamic> json) {
    return RecentItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      viewedAt: DateTime.tryParse(json['viewedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class RecentViewedNotifier extends StateNotifier<List<RecentItem>> {
  RecentViewedNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_recentViewedKey);
    if (jsonStr == null) return;

    try {
      final list = (jsonDecode(jsonStr) as List)
          .map((e) => RecentItem.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {
      // corrupted data - reset
      state = [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_recentViewedKey, jsonStr);
  }

  Future<void> add(String id, String name) async {
    // Remove existing entry for same id
    final filtered = state.where((item) => item.id != id).toList();

    // Add to front
    final newItem = RecentItem(id: id, name: name, viewedAt: DateTime.now());
    final updated = [newItem, ...filtered];

    // Keep max items
    state = updated.length > _maxRecentItems
        ? updated.sublist(0, _maxRecentItems)
        : updated;

    await _save();
  }

  Future<void> clear() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentViewedKey);
  }
}

final recentViewedProvider =
    StateNotifierProvider<RecentViewedNotifier, List<RecentItem>>((ref) {
  return RecentViewedNotifier();
});
