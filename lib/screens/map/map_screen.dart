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
import '../../core/utils/establish_type_helper.dart';
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
  String _currentAddress = '';
  bool _showList = false;
  bool _needsResearch = false;

  List<CustomOverlay> _overlays = [];
  final Map<String, MapMarker> _markerDataMap = {};
  final ValueNotifier<MapMarker?> _selectedMarkerNotifier = ValueNotifier(null);
  String? _selectedMarkerId;
  static const int _markerLimit = 20;
  static const double _radiusKm = 3.0;
  LatLng? _lastMapCenter;
  LatLng? _lastLoadedCenter;
  bool _mapReady = false;

  static final LatLng _defaultCenter = LatLng(37.5666805, 126.9784147);

  static String _buildOverlayContent(String hexColor, {bool selected = false}) {
    if (selected) {
      return '<div style="cursor:pointer;line-height:0;">'
          '<svg xmlns="http://www.w3.org/2000/svg" width="48" height="60" viewBox="0 0 36 46">'
          '<path d="M18 0C8.06 0 0 8.06 0 18c0 13.5 18 28 18 28s18-14.5 18-28C36 8.06 27.94 0 18 0z" fill="#$hexColor"/>'
          '<circle cx="18" cy="18" r="8" fill="white"/>'
          '</svg>'
          '</div>';
    }
    return '<div style="cursor:pointer;line-height:0;">'
        '<svg xmlns="http://www.w3.org/2000/svg" width="28" height="36" viewBox="0 0 36 46">'
        '<path d="M18 0C8.06 0 0 8.06 0 18c0 13.5 18 28 18 28s18-14.5 18-28C36 8.06 27.94 0 18 0z" fill="#$hexColor"/>'
        '<circle cx="18" cy="18" r="8" fill="white"/>'
        '</svg>'
        '</div>';
  }

  @override
  void initState() {
    super.initState();
    // 검색에서 "지도에서 보기" 감지
    ref.listenManual(mapFocusLocationProvider, (prev, next) {
      if (next != null && _mapReady && _mapController != null) {
        final loc = next;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(mapFocusLocationProvider.notifier).state = null;
          _mapController?.panTo(LatLng(loc.lat, loc.lng));
          _loadMarkersAndUpdateAddress(loc.lat, loc.lng);
        });
      }
    });
  }

  @override
  void dispose() {
    _selectedMarkerNotifier.dispose();
    super.dispose();
  }

  Future<void> _requestLocationAndLoadMarkers() async {
    // 검색에서 "지도에서 보기"로 넘어온 경우
    final focusLocation = ref.read(mapFocusLocationProvider);
    if (focusLocation != null) {
      ref.read(mapFocusLocationProvider.notifier).state = null;
      if (_mapController != null) {
        await _mapController!.panTo(
            LatLng(focusLocation.lat, focusLocation.lng));
      }
      _loadMarkersAndUpdateAddress(focusLocation.lat, focusLocation.lng);
      return;
    }

    try {
      final position = await ref.read(currentPositionProvider.future);
      if (position != null && _mapController != null) {
        _moveToPosition(position);
        _loadMarkersAndUpdateAddress(position.latitude, position.longitude);
      }
    } catch (e) {
      _loadMarkersAndUpdateAddress(
          _defaultCenter.latitude, _defaultCenter.longitude);
    }
  }

  Future<void> _updateAddress(double lat, double lng) async {
    final service = ref.read(locationServiceProvider);
    final placemarks = await service.getAddressFromLocation(lat, lng);
    if (placemarks.isEmpty) return;
    final place = placemarks.first;
    final area = place.administrativeArea ?? '';
    final sub = place.subLocality?.isNotEmpty == true
        ? place.subLocality!
        : place.locality ?? '';
    final address = sub.isNotEmpty ? '$area $sub' : area;
    if (mounted && address.isNotEmpty) {
      setState(() => _currentAddress = address);
    }
  }

  Future<void> _loadMarkersAndUpdateAddress(double lat, double lng) async {
    await _loadMarkers(lat, lng);
    _updateAddress(lat, lng);
    setState(() {
      _lastLoadedCenter = LatLng(lat, lng);
      _needsResearch = false;
    });
  }

  Future<void> _loadMarkers(double lat, double lng) async {
    if (_mapController == null) return;

    try {
      final markersData = await ref.read(mapMarkersProvider((
        lat: lat,
        lng: lng,
        radiusKm: _radiusKm,
        type: null,
        limit: _markerLimit,
      )).future);

      final newDataMap = <String, MapMarker>{};
      for (final markerData in markersData) {
        newDataMap[markerData.id] = markerData;
      }

      setState(() {
        _markerDataMap
          ..clear()
          ..addAll(newDataMap);
        _rebuildOverlays();
      });
    } catch (e) {
      debugPrint('마커 로드 실패: $e');
    }
  }

  void _rebuildOverlays() {
    const primaryHex = '3549FF';
    _overlays = _markerDataMap.values.map((m) {
      final isSelected = m.id == _selectedMarkerId;
      return CustomOverlay(
        customOverlayId: m.id,
        latLng: LatLng(m.lat, m.lng),
        content: _buildOverlayContent(primaryHex, selected: isSelected),
        xAnchor: 0.5,
        yAnchor: 1.0,
      );
    }).toList();
  }

  void _selectMarker(String? markerId) {
    final previousId = _selectedMarkerId;
    _selectedMarkerId = markerId;
    if (markerId != null) {
      _selectedMarkerNotifier.value = _markerDataMap[markerId];
    } else {
      _selectedMarkerNotifier.value = null;
    }

    final idsToRefresh = <String>[
      if (previousId != null) previousId,
      if (markerId != null && markerId != previousId) markerId,
    ];
    if (_mapController != null && idsToRefresh.isNotEmpty) {
      final keepIds = _markerDataMap.keys
          .where((id) => !idsToRefresh.contains(id))
          .toList();
      _mapController!.clearCustomOverlay(overlayIds: keepIds);
    }

    setState(() => _rebuildOverlays());
  }

  void _onOverlayTapped(String customOverlayId, LatLng latLng) {
    _selectMarker(customOverlayId);
    setState(() => _showList = false);
  }

  void _closeBottomSheet() {
    _selectMarker(null);
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
        _loadMarkersAndUpdateAddress(position.latitude, position.longitude);
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

  void _researchHere() {
    final center = _lastMapCenter;
    if (center != null) {
      _loadMarkersAndUpdateAddress(center.latitude, center.longitude);
    }
  }

  void _focusMarker(MapMarker marker) async {
    setState(() => _showList = false);
    _selectMarker(marker.id);
    if (_mapController != null) {
      await _mapController!.panTo(LatLng(marker.lat, marker.lng));
    }
  }

  Widget _buildNearbyMarkersList(List<MapMarker> markers) {
    return Column(
      children: [
        // 헤더 + 닫기
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            children: [
              Text('주변 유치원', style: AppTextStyles.headline6),
              const SizedBox(width: 8),
              Text(
                '${markers.length}개',
                style: AppTextStyles.body2.copyWith(color: AppColors.primary),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _showList = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: markers.isEmpty
              ? Center(
                  child: Text(
                    '주변에 유치원이 없습니다',
                    style:
                        AppTextStyles.body2.copyWith(color: AppColors.gray500),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: markers.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final marker = markers[index];
                    final typeColor =
                        EstablishTypeHelper.getColor(marker.establishType);
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          EstablishTypeHelper.getIcon(marker.establishType),
                          color: typeColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        marker.name,
                        style: AppTextStyles.body2
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        marker.address ?? marker.establishType,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.gray500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.gray400),
                      onTap: () => _focusMarker(marker),
                      onLongPress: () => context.push('/detail/${marker.id}'),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(fontSize: 16, color: AppColors.gray600),
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

    final markers = _markerDataMap.values.toList();
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // 지도
          KakaoMap(
            center: initialCenter,
            currentLevel: AppConstants.defaultMapLevel,
            customOverlays: _overlays,
            onMapCreated: (KakaoMapController controller) {
              _mapController = controller;
              _mapReady = true;
              _requestLocationAndLoadMarkers();
            },
            onCustomOverlayTap: _onOverlayTapped,
            onCameraIdle: (LatLng latLng, int zoomLevel) {
              _lastMapCenter = latLng;
              // 이전 로드 위치와 일정 거리 이상 차이나면 재검색 표시
              if (_lastLoadedCenter != null) {
                final moved = _hasMoved(_lastLoadedCenter!, latLng);
                if (moved && !_needsResearch) {
                  setState(() => _needsResearch = true);
                }
              }
            },
          ),

          // 상단: 현위치 주소 + 목록 버튼
          Positioned(
            top: safeTop + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // 현위치 주소 칩
                if (_currentAddress.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          _currentAddress,
                          style: AppTextStyles.body2
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                // 목록 보기 버튼
                Semantics(
                  label: _showList ? '지도 보기' : '목록 보기',
                  button: true,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _showList = !_showList;
                      _selectedMarkerNotifier.value = null;
                    }),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _showList ? Icons.map : Icons.list,
                        size: 20,
                        color: AppColors.gray700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // "현 지도에서 재검색" 버튼
          if (_needsResearch && !_showList)
            Positioned(
              top: safeTop + 56,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _researchHere,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '현 지도에서 재검색',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 현위치 FAB
          if (!_showList)
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

          // 유치원 목록 패널
          AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: _showList ? safeTop + 52 : MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              bottom: _showList ? 0 : -MediaQuery.of(context).size.height,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: _buildNearbyMarkersList(markers),
              ),
            ),

          // 마커 선택 시 바텀시트
          if (!_showList)
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
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
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

  bool _hasMoved(LatLng a, LatLng b) {
    return (a.latitude - b.latitude).abs() > AppConstants.mapMoveThreshold ||
        (a.longitude - b.longitude).abs() > AppConstants.mapMoveThreshold;
  }

}
