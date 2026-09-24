part of 'index.dart';

// ==========================================
// CLASS: AppInfoBase
// ==========================================

/// Common class for all structures provided by [AppInfoData]
abstract class AppInfoBase {
  /// Represent results as JSON map
  Map<String, dynamic> toJson();

  /// Pretty print the JSON representation of the informational object
  void prettyPrint() {
    const encoder = JsonEncoder.withIndent('  ');
    final data = toJson();
    for (final k in data.keys) {
      if (data[k] is Map) {
        data[k] = encoder.convert(toJson());
      }
    }
    // Printing is the purpose of this method.
    // ignore: avoid_print
    print(encoder.convert(toJson()));
  }
}

// ==========================================
// CLASS: AppInfoData
// ==========================================

/// Object encapsulating the populated [AppPackageInfo], [AppPlatformInfo], and [AppTargetInfo] instances.
class AppInfoData {
  AppInfoData._({
    required this.package,
    required this.platform,
    required this.target,
  });

  /// Information about the installed package and version
  final AppPackageInfo package;

  /// Information about the platform for which the app was built
  final AppPlatformInfo platform;

  /// Information about the platform on which the app is currently executing
  final AppTargetInfo target;

  /// Retrieve an [AppInfoData] instance pre-populated with package, platform, and target data
  static Future<AppInfoData> get() async {
    WidgetsFlutterBinding.ensureInitialized();
    return AppInfoData._(
      package: AppPackageInfo._(data: await PackageInfo.fromPlatform()),
      platform: AppPlatformInfo._(data: await DeviceInfoPlugin().deviceInfo),
      target: AppTargetInfo._(
        // The implicit view is the primary full-screen view and, unlike
        // `PlatformDispatcher.instance.views.first`, is well defined when
        // more than one view exists.
        data: MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.implicitView!,
        ),
      ),
    );
  }
}

// ==========================================
// CLASS: AppInfo
// ==========================================

/// [InheritedWidget] to distribute [AppInfoData] to application widget tree
class AppInfo extends InheritedWidget {
  /// Create an [AppInfo] InheritedWidget with [AppInfoData] instance
  const AppInfo({required this.data, required super.child, super.key});

  /// Instance of [AppInfoData] provided by [AppInfo] [InheritedWidget]
  final AppInfoData data;

  /// Denotes app was built for web, same as [kIsWeb]
  // ignore: prefer_const_declarations
  static final bool isWeb = kIsWeb;

  /// Denotes app was built for a desktop platform
  static final bool isDesktopPlatform =
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  /// Denotes app was built for a mobile platform
  static final bool isMobilePlatform = Platform.isAndroid || Platform.isIOS;

  /// Denotes app is running for a desktop target
  static final bool isDesktopTarget = [
    TargetPlatform.linux,
    TargetPlatform.macOS,
    TargetPlatform.windows,
  ].contains(defaultTargetPlatform);

  /// Denotes app was built for web and is running on a desktop browser
  static final bool isDesktopWebTarget = isWeb && isDesktopTarget;

  /// Denotes app is running for a mobile target
  static final bool isMobileTarget = [
    TargetPlatform.iOS,
    TargetPlatform.android,
  ].contains(defaultTargetPlatform);

  /// Denotes app was built for web and is running on a mobile browser
  static final bool isMobileWebTarget = isWeb && isMobileTarget;

  /// Returns an instance of [AppInfoData] from [AppInfo] InheritedWidget
  static AppInfoData of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppInfo>();
    assert(result != null, 'No AppInfo InheritedWidget found in context');
    return result!.data;
  }

  @override
  bool updateShouldNotify(AppInfo oldWidget) => false;
}
