import 'dart:ui' show Size;

import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
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

  group('AppTargetInfo isTablet', () {
    // The test target platform defaults to android, i.e. a mobile target.
    testWidgets('false when shortest side is below the 550 breakpoint', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(400, 800)
        ..devicePixelRatio = 1.0;
      final data = await AppInfoData.get();
      expect(data.target.isMobile, isTrue);
      expect(data.target.isTablet, isFalse);
    });

    testWidgets('true when shortest side reaches the 550 breakpoint', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(550, 900)
        ..devicePixelRatio = 1.0;
      final data = await AppInfoData.get();
      expect(data.target.isTablet, isTrue);
    });

    testWidgets('true when shortest side exceeds the 550 breakpoint', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(800, 1200)
        ..devicePixelRatio = 1.0;
      final data = await AppInfoData.get();
      expect(data.target.isTablet, isTrue);
    });
  });
}
