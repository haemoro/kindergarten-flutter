import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdManager {
  static const String _deviceIdKey = 'app_device_id';
  static DeviceIdManager? _instance;
  static DeviceIdManager get instance => _instance ??= DeviceIdManager._();

  DeviceIdManager._();

  String? _cachedDeviceId;

  /// 디바이스 ID 가져오기 (없으면 생성 후 저장)
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      deviceId = await _generateDeviceId();
      await prefs.setString(_deviceIdKey, deviceId);
    }

    _cachedDeviceId = deviceId;
    return deviceId;
  }

  /// 디바이스 ID 생성
  Future<String> _generateDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        return 'web_${webInfo.userAgent?.hashCode ?? _generateRandomId()}_${_generateRandomSuffix()}';
      }

      final info = await deviceInfo.deviceInfo;
      final data = info.data;
      final platform = data['systemName'] ?? data['board'] ?? 'unknown';
      return '${platform}_${_generateRandomId()}_${_generateRandomSuffix()}';
    } catch (e) {
      return 'unknown_${_generateRandomId()}_${_generateRandomSuffix()}';
    }
  }

  /// 랜덤 ID 생성 (UUID 형태)
  String _generateRandomId() {
    final random = Random();
    return '${random.nextInt(0xFFFFFFFF).toRadixString(16).padLeft(8, '0')}-'
           '${random.nextInt(0xFFFF).toRadixString(16).padLeft(4, '0')}-'
           '${random.nextInt(0xFFFF).toRadixString(16).padLeft(4, '0')}-'
           '${random.nextInt(0xFFFF).toRadixString(16).padLeft(4, '0')}-'
           '${random.nextInt(0xFFFFFFFFFFFF).toRadixString(16).padLeft(12, '0')}';
  }

  /// 랜덤 접미사 생성 (중복 방지)
  String _generateRandomSuffix() {
    final random = Random();
    return random.nextInt(999999).toString().padLeft(6, '0');
  }

  /// 캐시된 디바이스 ID 초기화 (테스트용)
  void clearCache() {
    _cachedDeviceId = null;
  }
}