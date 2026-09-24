import 'dart:convert' show jsonEncode;
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'src/fake_device_info_platform.dart';

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Test App',
      packageName: 'com.example.test_app',
      version: '2.1.3',
      buildNumber: '42',
      buildSignature: '',
    );
    DeviceInfoPlatform.instance = FakeDeviceInfoPlatform();
  });

  group('AppInfoData.get', () {
    testWidgets('populates package, platform, and target info', (tester) async {
      final data = await AppInfoData.get();

      // Package info flowed through from the mocked platform
      expect(data.package.packageName, 'com.example.test_app');

      // Platform info reflects the host platform
      expect(data.platform.isWeb, kIsWeb);
      expect(data.platform.isMacOS, !kIsWeb && Platform.isMacOS);
      expect(data.platform.isAndroid, !kIsWeb && Platform.isAndroid);
      expect(data.platform.isDesktop, AppInfo.isDesktopPlatform);
      expect(data.platform.isMobile, AppInfo.isMobilePlatform);
      expect(data.platform.operatingSystem, Platform.operatingSystem);
      if (Platform.isMacOS) {
        expect(data.platform.device, isA<MacOsDeviceInfo>());
      }

      // Target info reflects the test target platform
      expect(data.target.defaultPlatform, defaultTargetPlatform);
      final isAndroidTarget = defaultTargetPlatform == TargetPlatform.android;
      expect(data.target.isAndroid, isAndroidTarget);
      expect(data.target.isMobile, AppInfo.isMobileTarget);
    });

    testWidgets('platform deviceJson mirrors device data', (tester) async {
      final data = await AppInfoData.get();
      expect(data.platform.deviceJson['computerName'], 'Test Computer');
    });

    testWidgets('platform toJson is JSON-encodable', (tester) async {
      final data = await AppInfoData.get();
      expect(jsonEncode(data.platform.toJson()), isA<String>());
    });

    testWidgets(
      'non-encodable device data values fall back to string representation',
      (tester) async {
        DeviceInfoPlatform.instance = FakeDeviceInfoPlatform(
          extraData: {'custom': Object()},
        );
        final data = await AppInfoData.get();
        expect(data.platform.deviceJson['custom'], isA<String>());
      },
      // Custom data injection is only supported on the macOS test host.
      skip: !Platform.isMacOS,
    );

    testWidgets('target toJson contains platform flags', (tester) async {
      final data = await AppInfoData.get();
      final json = data.target.toJson();
      expect(json['defaultPlatform'], defaultTargetPlatform.name);
      expect(json['isTablet'], data.target.isTablet);
      expect(json['isMobile'], data.target.isMobile);
    });
  });
}
