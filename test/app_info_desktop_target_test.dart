import 'dart:ui' show Size;

import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride, kIsWeb;
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'src/fake_device_info_platform.dart';

/// The [AppInfo] target flags are `static final`, so each test applies the
/// platform override before the flags are evaluated for the first time. The
/// override is restored before the test body ends, as the test binding
/// requires.
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

  group('AppInfo desktop target flags', () {
    testWidgets('desktop target is active and mobile target is not', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        expect(AppInfo.isDesktopTarget, isTrue);
        expect(AppInfo.isMobileTarget, isFalse);
        expect(AppInfo.isDesktopWebTarget, kIsWeb);
        expect(AppInfo.isMobileWebTarget, isFalse);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('isTablet stays false on a desktop target', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        tester.view
          ..physicalSize = const Size(1200, 800)
          ..devicePixelRatio = 1.0;
        final data = await AppInfoData.get();
        expect(data.target.defaultPlatform, TargetPlatform.macOS);
        expect(data.target.isDesktop, isTrue);
        expect(data.target.isTablet, isFalse);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });
}
