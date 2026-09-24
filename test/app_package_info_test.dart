import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'src/fake_device_info_platform.dart';

void main() {
  setUp(() {
    DeviceInfoPlatform.instance = FakeDeviceInfoPlatform();
  });

  group('AppPackageInfo version parsing', () {
    testWidgets('parses version with build number', (tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'com.example.test_app',
        version: '2.1.3',
        buildNumber: '42',
        buildSignature: 'test-signature',
        installerStore: 'test-store',
      );
      final data = await AppInfoData.get();
      expect(data.package.appName, 'Test App');
      expect(data.package.packageName, 'com.example.test_app');
      expect(data.package.buildNumber, '42');
      expect(data.package.buildSignature, 'test-signature');
      expect(data.package.installerStore, 'test-store');
      expect(data.package.version, Version.parse('2.1.3+42'));
      expect(data.package.versionWithoutBuild, Version.parse('2.1.3'));
    });

    testWidgets('parses version without build number', (tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'com.example.test_app',
        version: '1.0.0',
        buildNumber: '',
        buildSignature: '',
      );
      final data = await AppInfoData.get();
      expect(data.package.version, Version.parse('1.0.0'));
      expect(data.package.versionWithoutBuild, Version.parse('1.0.0'));
    });

    testWidgets('falls back to version 0 on invalid version string', (
      tester,
    ) async {
      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'com.example.test_app',
        version: 'not.a.version',
        buildNumber: '42',
        buildSignature: '',
      );
      final data = await AppInfoData.get();
      expect(data.package.version, Version.parse('0'));
      expect(data.package.versionWithoutBuild, Version.parse('0'));
    });

    testWidgets('toJson returns stringified values', (tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'com.example.test_app',
        version: '2.1.3',
        buildNumber: '42',
        buildSignature: '',
      );
      final data = await AppInfoData.get();
      final json = data.package.toJson();
      expect(json['appName'], 'Test App');
      expect(json['packageName'], 'com.example.test_app');
      expect(json['version'], '2.1.3+42');
      expect(json['versionWithoutBuild'], '2.1.3');
    });
  });
}
