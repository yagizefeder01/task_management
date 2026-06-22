import 'package:flutter/foundation.dart';

class AdConstants {
  AdConstants._();

  // Production AdMob IDs.
  static const String androidAppId = 'ca-app-pub-3584119358325239~1537131887';
  static const String iosAppId = 'ca-app-pub-3584119358325239~2889476072';
  static const String androidBannerUnitId =
      'ca-app-pub-3584119358325239/8549262797';
  static const String iosBannerUnitId =
      'ca-app-pub-3584119358325239/4501940647';
  static const String androidInterstitialUnitId =
      'ca-app-pub-3584119358325239/2067348996';
  static const String iosInterstitialUnitId =
      'ca-app-pub-3584119358325239/7265925114';

  static bool get isSupportedPlatform {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static String? get bannerUnitId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidBannerUnitId;
      case TargetPlatform.iOS:
        return iosBannerUnitId;
      default:
        return null;
    }
  }

  static String? get interstitialUnitId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidInterstitialUnitId;
      case TargetPlatform.iOS:
        return iosInterstitialUnitId;
      default:
        return null;
    }
  }
}
