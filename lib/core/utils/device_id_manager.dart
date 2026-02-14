import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
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
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return 'android_${androidInfo.fingerprint}_${_generateRandomSuffix()}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return 'ios_${iosInfo.identifierForVendor ?? _generateRandomId()}_${_generateRandomSuffix()}';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return 'macos_${macInfo.systemGUID ?? _generateRandomId()}_${_generateRandomSuffix()}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return 'windows_${windowsInfo.deviceId}_${_generateRandomSuffix()}';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return 'linux_${linuxInfo.machineId ?? _generateRandomId()}_${_generateRandomSuffix()}';
      } else {
        // 웹이나 기타 플랫폼
        return 'web_${_generateRandomId()}_${_generateRandomSuffix()}';
      }
    } catch (e) {
      // 디바이스 정보 가져오기 실패 시 완전 랜덤 ID 생성
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