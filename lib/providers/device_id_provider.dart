import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/device_id_manager.dart';

// DeviceId Provider
final deviceIdProvider = FutureProvider<String>((ref) async {
  return await DeviceIdManager.instance.getDeviceId();
});