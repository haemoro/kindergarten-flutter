import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
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
  NaverMapController? _mapController;
  String? _selectedFilterType; // null = 전체
  Timer? _cameraDebounceTimer;

  // 기본 카메라 위치 (서울 시청)
  static const NLatLng _defaultTarget = NLatLng(37.5666805, 126.9784147);

  @override
  void dispose() {
    _cameraDebounceTimer?.cancel();
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
      _loadMarkers(_defaultTarget.latitude, _defaultTarget.longitude);
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

      final overlays = <NMarker>[];

      for (final markerData in markersData) {
        final marker = NMarker(
          id: markerData.id,
          position: NLatLng(markerData.lat, markerData.lng),
          iconTintColor: _getMarkerColor(markerData.establishType),
        );
        marker.setOnTapListener((overlay) {
          _onMarkerTapped(markerData);
        });
        overlays.add(marker);
      }

      await _mapController!.clearOverlays();
      await _mapController!.addOverlayAll(overlays.toSet());
    } catch (e) {
      debugPrint('마커 로드 실패: $e');
    }
  }

  Color _getMarkerColor(String establishType) {
    switch (establishType) {
      case '국공립':
      case '공립(병설)':
        return AppColors.markerPublic;
      case '사립':
      case '사립(사인)':
        return AppColors.markerPrivate;
      case '법인':
      case '사립(법인)':
        return AppColors.markerCorporation;
      default:
        return AppColors.markerOther;
    }
  }

  void _onMarkerTapped(MapMarker kindergarten) {
    _showBottomSheet(kindergarten);
  }

  void _showBottomSheet(MapMarker kindergarten) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => MarkerBottomSheet(
        kindergarten: kindergarten,
        onDetailPressed: () {
          Navigator.pop(sheetContext);
          context.push('/detail/${kindergarten.id}');
        },
      ),
    );
  }

  Future<void> _moveToPosition(Position position) async {
    if (_mapController == null) return;

    final cameraUpdate = NCameraUpdate.withParams(
      target: NLatLng(position.latitude, position.longitude),
      zoom: AppConstants.defaultMapZoom,
    )..setAnimation(
        animation: NCameraAnimation.easing,
        duration: const Duration(milliseconds: 500),
      );
    await _mapController!.updateCamera(cameraUpdate);
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
    final bounds = await _mapController!.getContentBounds();
    final centerLat =
        (bounds.northEast.latitude + bounds.southWest.latitude) / 2;
    final centerLng =
        (bounds.northEast.longitude + bounds.southWest.longitude) / 2;
    _loadMarkers(centerLat, centerLng);
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

    final initialTarget = currentPositionAsync.when(
      data: (position) => position != null
          ? NLatLng(position.latitude, position.longitude)
          : _defaultTarget,
      loading: () => _defaultTarget,
      error: (_, __) => _defaultTarget,
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
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: initialTarget,
                zoom: AppConstants.defaultMapZoom,
              ),
              locationButtonEnable: false,
              zoomGesturesFriction: 0.0,
            ),
            onMapReady: (NaverMapController controller) {
              _mapController = controller;
              _requestLocationAndLoadMarkers();
            },
            onCameraIdle: () {
              _cameraDebounceTimer?.cancel();
              _cameraDebounceTimer = Timer(
                AppConstants.mapCameraDebounceTime,
                () => _reloadMarkersAtCurrentPosition(),
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
