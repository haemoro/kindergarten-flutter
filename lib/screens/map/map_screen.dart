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
import '../../models/kindergarten_search.dart';
import '../../widgets/badge_chip.dart';
import 'widgets/marker_bottom_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  KakaoMapController? _mapController;
  Timer? _cameraDebounceTimer;
  String _currentAddress = '';
  bool _showList = false;

  List<CustomOverlay> _overlays = [];
  final Map<String, MapMarker> _markerDataMap = {};
  final ValueNotifier<MapMarker?> _selectedMarkerNotifier = ValueNotifier(null);
  String? _selectedMarkerId;

  // 텍스트 검색 관련
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounceTimer;
  List<KindergartenSearch> _searchResults = [];
  bool _isSearchMode = false;
  bool _isSearchLoading = false;
  LatLng? _lastMapCenter;

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
  void dispose() {
    _cameraDebounceTimer?.cancel();
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _selectedMarkerNotifier.dispose();
    super.dispose();
  }

  Future<void> _requestLocationAndLoadMarkers() async {
    try {
      final position = await ref.read(currentPositionProvider.future);
      if (position != null && _mapController != null) {
        _moveToPosition(position);
        _loadMarkers(position.latitude, position.longitude);
        _updateAddress(position.latitude, position.longitude);
      }
    } catch (e) {
      _loadMarkers(_defaultCenter.latitude, _defaultCenter.longitude);
      _updateAddress(_defaultCenter.latitude, _defaultCenter.longitude);
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

  Future<void> _loadMarkers(double lat, double lng) async {
    if (_mapController == null) return;

    try {
      final markersData = await ref.read(mapMarkersProvider((
        lat: lat,
        lng: lng,
        radiusKm: AppConstants.defaultRadius,
        type: null,
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

    // 변경된 마커만 강제 제거 후 재추가 (플러그인이 동일 ID content 변경을 무시하므로)
    final idsToRefresh = <String>[
      if (previousId != null) previousId,
      if (markerId != null && markerId != previousId) markerId,
    ];
    if (_mapController != null && idsToRefresh.isNotEmpty) {
      // 해당 ID들만 제거 (빈 리스트로 clear하면 전부 지워짐)
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
        _loadMarkers(position.latitude, position.longitude);
        _updateAddress(position.latitude, position.longitude);
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

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearchMode = false;
        _isSearchLoading = false;
      });
      return;
    }
    setState(() {
      _isSearchMode = true;
      _isSearchLoading = true;
    });
    _searchDebounceTimer = Timer(
      const Duration(milliseconds: 400),
      () => _performSearch(query.trim()),
    );
  }

  Future<void> _performSearch(String query) async {
    try {
      final repository = ref.read(kindergartenRepositoryProvider);
      final result = await repository.searchKindergartens(
        q: query,
        lat: _lastMapCenter?.latitude,
        lng: _lastMapCenter?.longitude,
        sort: 'distance',
        size: 20,
      );
      if (mounted) {
        setState(() {
          _searchResults = result.content;
          _isSearchLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearchLoading = false;
        });
      }
    }
  }

  void _exitSearchMode() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchMode = false;
      _searchResults = [];
      _showList = false;
    });
  }

  void _focusSearchResult(KindergartenSearch item) async {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchMode = false;
      _searchResults = [];
      _showList = false;
    });
    if (_mapController != null) {
      await _mapController!.panTo(LatLng(item.lat, item.lng));
    }
    _loadMarkers(item.lat, item.lng);
    _updateAddress(item.lat, item.lng);
  }

  void _focusMarker(MapMarker marker) async {
    setState(() => _showList = false);
    _selectMarker(marker.id);
    if (_mapController != null) {
      await _mapController!.panTo(LatLng(marker.lat, marker.lng));
    }
  }

  Widget _buildSearchResultsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text('검색 결과', style: AppTextStyles.headline6),
              if (!_isSearchLoading) ...[
                const SizedBox(width: 8),
                Text(
                  '${_searchResults.length}개',
                  style: AppTextStyles.body2.copyWith(color: AppColors.primary),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _isSearchLoading
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? '유치원 이름을 입력하세요'
                            : '검색 결과가 없습니다',
                        style: AppTextStyles.body2.copyWith(color: AppColors.gray500),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        final typeColor = EstablishTypeHelper.getColor(item.establishType);
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              EstablishTypeHelper.getIcon(item.establishType),
                              color: typeColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            item.address,
                            style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right, color: AppColors.gray400),
                          onTap: () => _focusSearchResult(item),
                          onLongPress: () => context.push('/detail/${item.id}'),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildNearbyMarkersList(List<MapMarker> markers) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text('주변 유치원', style: AppTextStyles.headline6),
              const SizedBox(width: 8),
              Text(
                '${markers.length}개',
                style: AppTextStyles.body2.copyWith(color: AppColors.primary),
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
                    style: AppTextStyles.body2.copyWith(color: AppColors.gray500),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: markers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final marker = markers[index];
                    final typeColor = EstablishTypeHelper.getColor(marker.establishType);
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
                        style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: BadgeChip.establishType(
                        label: marker.establishType,
                        establishType: marker.establishType,
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.gray400),
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

    final markers = _markerDataMap.values.toList();
    final searchBarTop = MediaQuery.of(context).padding.top + 8;
    const searchBarHeight = 48.0;

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
              _requestLocationAndLoadMarkers();
            },
            onCustomOverlayTap: _onOverlayTapped,
            onCameraIdle: (LatLng latLng, int zoomLevel) {
              _lastMapCenter = latLng;
              _cameraDebounceTimer?.cancel();
              _cameraDebounceTimer = Timer(
                AppConstants.mapCameraDebounceTime,
                () {
                  _loadMarkers(latLng.latitude, latLng.longitude);
                  _updateAddress(latLng.latitude, latLng.longitude);
                },
              );
            },
          ),

          // 줌 컨트롤 + 현위치 FAB
          if (!_showList)
            Positioned(
              top: searchBarTop + searchBarHeight + 16,
              right: 16,
              child: Column(
                children: [
                  _ZoomButton(
                    icon: Icons.add,
                    onTap: () async {
                      if (_mapController == null) return;
                      final level = await _mapController!.getLevel();
                      _mapController!.setLevel(level - 1);
                    },
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  Container(height: 1, width: 36, color: AppColors.gray200),
                  _ZoomButton(
                    icon: Icons.remove,
                    onTap: () async {
                      if (_mapController == null) return;
                      final level = await _mapController!.getLevel();
                      _mapController!.setLevel(level + 1);
                    },
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                ],
              ),
            ),
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

          // 검색바
          Positioned(
            top: searchBarTop,
            left: 16,
            right: 16,
            child: Container(
              height: searchBarHeight,
              padding: const EdgeInsets.only(left: 16, right: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _isSearchMode ? Icons.search : Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: _currentAddress.isNotEmpty
                            ? _currentAddress
                            : '유치원 이름 또는 주소로 검색',
                        hintStyle: AppTextStyles.body2.copyWith(
                          color: AppColors.gray500,
                          height: 1.0,
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      style: AppTextStyles.body2.copyWith(height: 1.0),
                      onChanged: (value) {
                        _onSearchChanged(value);
                        if (value.isNotEmpty && !_showList) {
                          setState(() {
                            _showList = true;
                            _selectedMarkerNotifier.value = null;
                          });
                        }
                      },
                      onTap: () {
                        if (!_showList) {
                          setState(() {
                            _showList = true;
                            _selectedMarkerNotifier.value = null;
                          });
                        }
                      },
                    ),
                  ),
                  if (_isSearchMode || _showList)
                    GestureDetector(
                      onTap: _exitSearchMode,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.close, color: AppColors.gray500, size: 20),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => setState(() {
                        _showList = !_showList;
                        _selectedMarkerNotifier.value = null;
                      }),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.keyboard_arrow_down, color: AppColors.gray500, size: 20),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 유치원 목록 패널
          if (_showList)
            Positioned(
              top: searchBarTop + searchBarHeight + 8,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: _isSearchMode
                    ? _buildSearchResultsList()
                    : _buildNearbyMarkersList(markers),
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

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _ZoomButton({
    required this.icon,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: borderRadius,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: AppColors.gray600),
        ),
      ),
    );
  }
}
