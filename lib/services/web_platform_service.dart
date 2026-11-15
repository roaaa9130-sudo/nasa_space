import 'web_platform_stub.dart'
    if (dart.library.html) 'web_platform_web.dart' as platform_impl;

class WebPlatformService {
  static void dismissSplashScreen([String reason = '']) {
    try {
      platform_impl.WebPlatformImpl.dismissSplashScreen(reason);
    } catch (_) {
      // No-op on platforms where web APIs are unavailable
    }
  }
}
