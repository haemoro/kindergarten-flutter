import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/location_providers.dart';
import '../../providers/kindergarten_providers.dart';
import '../../models/map_marker.dart';
import 'widgets/marker_bottom_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  KakaoMapController? _mapController;
  String? _selectedFilterType; // null = 전체
  Timer? _cameraDebounceTimer;

  // 카카오맵 CustomOverlay 목록 (색상 마커용)
  List<CustomOverlay> _overlays = [];
  // overlayId → MapMarker 매핑 (오버레이 탭 시 데이터 조회용)
  final Map<String, MapMarker> _markerDataMap = {};
  // 선택된 마커 (바텀시트 표시용, ValueNotifier로 KakaoMap 재빌드 방지)
  final ValueNotifier<MapMarker?> _selectedMarkerNotifier = ValueNotifier(null);

  // 기본 카메라 위치 (서울 시청)
  static final LatLng _defaultCenter = LatLng(37.5666805, 126.9784147);

  /// 설립유형 색상으로 핀 SVG HTML을 생성
  static String _buildOverlayContent(String hexColor) {
    return '<div style="cursor:pointer;line-height:0;">'
        '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="46" viewBox="0 0 36 46">'
        '<path d="M18 0C8.06 0 0 8.06 0 18c0 13.5 18 28 18 28s18-14.5 18-28C36 8.06 27.94 0 18 0z" fill="#$hexColor"/>'
        '<circle cx="18" cy="18" r="8" fill="white"/>'
        '</svg>'
        '</div>';
  }

  @override
  void dispose() {
    _cameraDebounceTimer?.cancel();
    _selectedMarkerNotifier.dispose();
    super.dispose();
  }

  Future<void> _requestLocationAndLoadMarkers() async {
    try {
      final position = await ref.read(currentPositionProvider.future);
      if (position != null && _mapController != null) {
        _moveToPosition(position);
        _loadMarkers(position.latitude, position.longitude);
      }
    } catch (e) {
      // 위치 권한 없어도 기본 위치에서 마커 로드
      _loadMarkers(_defaultCenter.latitude, _defaultCenter.longitude);
    }
  }

  Future<void> _loadMarkers(double lat, double lng) async {
    if (_mapController == null) return;

    try {
      final markersData = await ref.read(mapMarkersProvider((
        lat: lat,
        lng: lng,
        radiusKm: AppConstants.defaultRadius,
        type: _selectedFilterType,
      )).future);

      // 디버그: API에서 내려오는 실제 establishType 값 확인
      if (markersData.isNotEmpty) {
        final types = markersData.map((m) => m.establishType).toSet();
        debugPrint('📍 마커 데이터 establishType 종류: $types (필터: $_selectedFilterType)');
      }

      // 클라이언트 사이드 필터링 (백엔드 미지원 대비)
      final filtered = _selectedFilterType != null
          ? markersData
              .where((m) => m.establishType.contains(_selectedFilterType!))
              .toList()
          : markersData;
      debugPrint('📍 전체: ${markersData.length}개, 필터 후: ${filtered.length}개');

      final newOverlays = <CustomOverlay>[];
      final newDataMap = <String, MapMarker>{};

      // 프라이머리 색상 (3549FF) 고정
      const primaryHex = '3549FF';

      for (final markerData in filtered) {
        final overlay = CustomOverlay(
          customOverlayId: markerData.id,
          latLng: LatLng(markerData.lat, markerData.lng),
          content: _buildOverlayContent(primaryHex),
          xAnchor: 0.5,
          yAnchor: 1.0,
        );
        newOverlays.add(overlay);
        newDataMap[markerData.id] = markerData;
      }

      setState(() {
        _overlays = newOverlays;
        _markerDataMap
          ..clear()
          ..addAll(newDataMap);
      });
    } catch (e) {
      debugPrint('마커 로드 실패: $e');
    }
  }

  void _onOverlayTapped(String customOverlayId, LatLng latLng) {
    final markerData = _markerDataMap[customOverlayId];
    if (markerData != null) {
      _selectedMarkerNotifier.value = markerData;
    }
  }

  void _closeBottomSheet() {
    _selectedMarkerNotifier.value = null;
  }

  Future<void> _moveToPosition(Position position) async {
    if (_mapController == null) return;
    await _mapController!.panTo(
      LatLng(position.latitude, position.longitude),
    );
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      final position = await ref.read(currentPositionProvider.future);
      if (position != null) {
        _moveToPosition(position);
        _loadMarkers(position.latitude, position.longitude);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('현재 위치를 가져올 수 없습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('위치 오류: $e')),
        );
      }
    }
  }

  void _applyFilter(String? type) {
    setState(() {
      _selectedFilterType = type;
    });
    _reloadMarkersAtCurrentPosition();
  }

  Future<void> _reloadMarkersAtCurrentPosition() async {
    if (_mapController == null) return;
    final center = await _mapController!.getCenter();
    _loadMarkers(center.latitude, center.longitude);
  }

  @override
  Widget build(BuildContext context) {
    // 웹 플랫폼 미지원 처리
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('지도')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 64, color: AppColors.gray400),
              SizedBox(height: 16),
              Text(
                '지도는 모바일에서만 지원됩니다',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentPositionAsync = ref.watch(currentPositionProvider);

    final initialCenter = currentPositionAsync.when(
      data: (position) => position != null
          ? LatLng(position.latitude, position.longitude)
          : _defaultCenter,
      loading: () => _defaultCenter,
      error: (_, __) => _defaultCenter,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('지도'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (type) => _applyFilter(type),
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('전체')),
              const PopupMenuItem(value: '국공립', child: Text('국공립')),
              const PopupMenuItem(value: '사립', child: Text('사립')),
              const PopupMenuItem(value: '법인', child: Text('법인')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // 지도
          KakaoMap(
            center: initialCenter,
            currentLevel: AppConstants.defaultMapLevel,
            customOverlays: _overlays,
            onMapCreated: (KakaoMapController controller) {
              _mapController = controller;
              _requestLocationAndLoadMarkers();
            },
            onCustomOverlayTap: _onOverlayTapped,
            onCameraIdle: (LatLng latLng, int zoomLevel) {
              _cameraDebounceTimer?.cancel();
              _cameraDebounceTimer = Timer(
                AppConstants.mapCameraDebounceTime,
                () => _loadMarkers(latLng.latitude, latLng.longitude),
              );
            },
          ),

          // 현위치 이동 FAB
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'location',
              onPressed: _moveToCurrentLocation,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primary,
              child: const Icon(Icons.my_location),
            ),
          ),

          // 설립유형 필터 칩들 (상단 오버레이)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  children: [
                    _FilterChip(
                      label: '전체',
                      isSelected: _selectedFilterType == null,
                      color: AppColors.primary,
                      onSelected: () => _applyFilter(null),
                    ),
                    _FilterChip(
                      label: '국공립',
                      isSelected: _selectedFilterType == '국공립',
                      color: AppColors.publicType,
                      onSelected: () => _applyFilter('국공립'),
                    ),
                    _FilterChip(
                      label: '사립',
                      isSelected: _selectedFilterType == '사립',
                      color: AppColors.privateType,
                      onSelected: () => _applyFilter('사립'),
                    ),
                    _FilterChip(
                      label: '법인',
                      isSelected: _selectedFilterType == '법인',
                      color: AppColors.corporationType,
                      onSelected: () => _applyFilter('법인'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 마커 선택 시 바텀시트 (ValueNotifier로 KakaoMap 재빌드 없이 표시)
          ValueListenableBuilder<MapMarker?>(
            valueListenable: _selectedMarkerNotifier,
            builder: (context, selectedMarker, _) {
              if (selectedMarker == null) {
                return const SizedBox.shrink();
              }
              return Align(
                alignment: Alignment.bottomCenter,
                child: Material(
                  elevation: 8,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  child: MarkerBottomSheet(
                    kindergarten: selectedMarker,
                    onClose: _closeBottomSheet,
                    onDetailPressed: () {
                      _closeBottomSheet();
                      context.push('/detail/${selectedMarker.id}');
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      labelStyle: AppTextStyles.chipText.copyWith(
        color: isSelected ? Colors.white : color,
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color),
      onSelected: (_) => onSelected(),
    );
  }
}
