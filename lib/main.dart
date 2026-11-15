import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/lunabase_welcome_screen.dart';
import 'services/web_platform_service.dart';

void main() async {
  debugPrint('===============================================================');
  debugPrint('🚀 [NASA STARTUP] Starting NASA Space Exploration Engine 2026...');
  debugPrint('===============================================================');
  final startupWatch = Stopwatch()..start();

  // 1. Global Flutter error handlers to eliminate silent black screens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🚨 [NASA FLUTTER ERROR] ${details.exceptionAsString()}');
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('🚨 [NASA UI CRASH CAUGHT] ${details.exception}');
    return _buildGlobalErrorWidget(details);
  };

  // 2. Ensure WidgetsFlutterBinding is ready
  debugPrint('⏱️ [NASA STARTUP 1/4] Initializing WidgetsFlutterBinding...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('✅ [NASA STARTUP 1/4] WidgetsFlutterBinding ready (${startupWatch.elapsedMilliseconds}ms).');

  // 3. Strictly disable Google Fonts runtime network fetching
  // This permanently prevents "TypeError: Failed to fetch" crashes on web startup
  debugPrint('⏱️ [NASA STARTUP 2/4] Enforcing Google Fonts offline safety policy...');
  try {
    GoogleFonts.config.allowRuntimeFetching = false;
    debugPrint('✅ [NASA STARTUP 2/4] GoogleFonts runtime network fetching disabled.');
  } catch (e) {
    debugPrint('⚠️ [NASA STARTUP 2/4] GoogleFonts config warning: $e');
  }

  // 4. Safe Hive initialization with timeouts — storage never blocks UI mounting
  debugPrint('⏱️ [NASA STARTUP 3/4] Initializing storage subsystem...');
  try {
    await Hive.initFlutter().timeout(
      const Duration(milliseconds: 800),
      onTimeout: () {
        debugPrint('⚠️ [NASA STARTUP] Hive.initFlutter timed out (800ms) — continuing.');
      },
    );

    try {
      if (!Hive.isBoxOpen('nasa_space_settings')) {
        await Hive.openBox('nasa_space_settings').timeout(
          const Duration(milliseconds: 800),
          onTimeout: () {
            debugPrint('⚠️ [NASA STARTUP] Hive.openBox timed out (800ms) — using memory state.');
            throw TimeoutException('Hive openBox timeout');
          },
        );
      }
    } catch (e) {
      debugPrint('⚠️ [NASA STARTUP] Hive box open notice: $e');
    }
  } catch (e, stack) {
    debugPrint('⚠️ [NASA STARTUP 3/4] Hive initialization fallback active: $e\n$stack');
  }

  // 5. Mount the root widget tree immediately
  debugPrint('⏱️ [NASA STARTUP 4/4] Launching runApp(NasaSpaceApp)...');
  runApp(
    const ProviderScope(
      child: NasaSpaceApp(),
    ),
  );
  debugPrint('🚀 [NASA STARTUP] runApp() initiated successfully in ${startupWatch.elapsedMilliseconds}ms.');
}

/// Fallback-safe text theme using system fonts with zero network requests
TextTheme _buildSafeTextTheme() {
  final base = ThemeData.dark().textTheme;
  try {
    if (!kIsWeb) {
      try {
        return GoogleFonts.rajdhaniTextTheme(base);
      } catch (_) {}
    }
    return base.apply(
      fontFamily: 'sans-serif',
      fontFamilyFallback: const [
        'Segoe UI',
        'Roboto',
        'Arial',
        'Cairo',
        'Rajdhani',
        'sans-serif',
      ],
    );
  } catch (e) {
    return base;
  }
}

/// Root Application Widget: 100% Stateless & Provider-Isolated
/// Renders MaterialApp immediately without waiting for any async provider or Hive state
class NasaSpaceApp extends StatelessWidget {
  const NasaSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🛰️ [NASA UI] Building NasaSpaceApp root (Stateless, 100% isolated)...');

    final appTextTheme = _buildSafeTextTheme();

    return MaterialApp(
      title: 'NASA 3D Mars & Moon Exploration (2026)',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: const Color(0xFF38BDF8),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFFF97316),
          surface: Color(0xFF080F1E),
        ),
        textTheme: appTextTheme,
      ),
      builder: (context, child) => child ?? const _SafeFallbackScreen(),
      home: const _AppRootLifecycleWrapper(
        child: LunabaseWelcomeScreen(),
      ),
    );
  }
}

/// Lifecycle wrapper that dismisses the HTML splash screen as soon as the first frame is painted
class _AppRootLifecycleWrapper extends StatefulWidget {
  final Widget child;
  const _AppRootLifecycleWrapper({required this.child});

  @override
  State<_AppRootLifecycleWrapper> createState() => _AppRootLifecycleWrapperState();
}

class _AppRootLifecycleWrapperState extends State<_AppRootLifecycleWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🎉 [NASA APP] First Flutter root frame rendered! Dismissing splash screen.');
      WebPlatformService.dismissSplashScreen('Root Flutter frame rendered');
    });

    // Redundant safety timer: dismiss splash after 400ms even if post-frame callback was deferred
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        WebPlatformService.dismissSplashScreen('Lifecycle safety 400ms timer');
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Styled NASA Diagnostic Screen (displayed if any widget crashes instead of a black screen)
Widget _buildGlobalErrorWidget(FlutterErrorDetails details) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF060D1A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF97316), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Color(0x33F97316), blurRadius: 24, spreadRadius: 2),
              BoxShadow(color: Colors.black, blurRadius: 16),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF97316).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFFF97316)),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF97316), size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'NASA MISSION TELEMETRY DIAGNOSTIC',
                style: TextStyle(
                  color: Color(0xFFF97316),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                details.exceptionAsString(),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => WebPlatformService.dismissSplashScreen('Diagnostic Reload'),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'RESUME MISSION CREW STATION',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, letterSpacing: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Fallback screen in case a child widget is null
class _SafeFallbackScreen extends StatelessWidget {
  const _SafeFallbackScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF020617),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
      ),
    );
  }
}
