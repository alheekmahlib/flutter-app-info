import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';

/// Fake [DeviceInfoPlatform] that serves device info without hitting
/// platform channels. Returns a host-appropriate model so the internal
/// platform casts in `DeviceInfoPlugin` succeed.
class FakeDeviceInfoPlatform extends DeviceInfoPlatform {
  /// Creates a fake platform that merges [extraData] into the device map.
  FakeDeviceInfoPlatform({this.extraData = const {}});

  /// Additional entries merged into the served device data map.
  final Map<String, dynamic> extraData;

  @override
  Future<BaseDeviceInfo> deviceInfo() async {
    if (Platform.isLinux) {
      return LinuxDeviceInfo(
        name: 'Test Linux',
        id: 'linux',
        prettyName: 'Test Linux',
        machineId: 'test-machine-id',
      );
    }
    return MacOsDeviceInfo.fromMap({..._macOsData, ...extraData});
  }

  static const Map<String, dynamic> _macOsData = {
    'computerName': 'Test Computer',
    'hostName': 'test.local',
    'arch': 'arm64',
    'model': 'Mac14,2',
    'modelName': 'MacBook Pro',
    'kernelVersion': '24.0.0',
    'osRelease': '15.0',
    'majorVersion': 15,
    'minorVersion': 0,
    'patchVersion': 0,
    'activeCPUs': 8,
    'memorySize': 16,
    'cpuFrequency': 3,
    'systemGUID': 'test-guid',
  };
}
