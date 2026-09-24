import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show Builder, SizedBox;
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

  group('AppInfo static flags', () {
    testWidgets('isWeb matches kIsWeb', (tester) async {
      expect(AppInfo.isWeb, kIsWeb);
    });

    testWidgets('desktop and mobile targets are mutually exclusive', (
      tester,
    ) async {
      expect(AppInfo.isDesktopTarget ^ AppInfo.isMobileTarget, isTrue);
      final isDesktopWeb = AppInfo.isWeb && AppInfo.isDesktopTarget;
      final isMobileWeb = AppInfo.isWeb && AppInfo.isMobileTarget;
      expect(AppInfo.isDesktopWebTarget, isDesktopWeb);
      expect(AppInfo.isMobileWebTarget, isMobileWeb);
    });
  });

  group('AppInfo InheritedWidget', () {
    testWidgets('of returns the provided AppInfoData instance', (tester) async {
      final data = await AppInfoData.get();
      late AppInfoData retrieved;
      await tester.pumpWidget(
        AppInfo(
          data: data,
          child: Builder(
            builder: (context) {
              retrieved = AppInfo.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(retrieved, same(data));
    });

    testWidgets('of throws when no AppInfo widget is in scope', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            AppInfo.of(context);
            return const SizedBox();
          },
        ),
      );
      expect(tester.takeException(), isNotNull);
    });

    testWidgets('updateShouldNotify never notifies', (tester) async {
      final first = await AppInfoData.get();
      final second = await AppInfoData.get();
      final oldWidget = AppInfo(data: first, child: const SizedBox());
      final newWidget = AppInfo(data: second, child: const SizedBox());
      expect(newWidget.updateShouldNotify(oldWidget), isFalse);
    });
  });
}
