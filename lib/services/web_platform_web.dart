// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class WebPlatformImpl {
  static void dismissSplashScreen([String reason = '']) {
    try {
      debugPrint('🌐 [WEB PLATFORM] Attempting to dismiss web splash screen ($reason)...');
      if (js.context.hasProperty('dismissNasaSplash')) {
        js.context.callMethod('dismissNasaSplash', [reason.isNotEmpty ? reason : 'Flutter UI mounted']);
      } else {
        final loader = html.document.getElementById('loading-indicator');
        if (loader != null) {
          loader.style.opacity = '0';
          loader.style.pointerEvents = 'none';
          Future.delayed(const Duration(milliseconds: 600), () {
            loader.remove();
          });
        }
      }
      debugPrint('✅ [WEB PLATFORM] Web splash screen dismiss triggered.');
    } catch (e) {
      debugPrint('⚠️ [WEB PLATFORM] dismissSplashScreen warning: $e');
    }
  }
}
