import 'package:flutter/material.dart';
import 'three_js_view_stub.dart'
    if (dart.library.html) 'three_js_view_web.dart' as platform_impl;

class ThreeJsCanvasWidget extends StatefulWidget {
  final String scenePath;
  final String viewId;
  final Function(dynamic message)? onMessage;
  final Widget? overlay;
  final bool ignorePointer;

  const ThreeJsCanvasWidget({
    super.key,
    required this.scenePath,
    required this.viewId,
    this.onMessage,
    this.overlay,
    this.ignorePointer = false,
  });

  static void sendMessage(String viewId, Map<String, dynamic> message) {
    platform_impl.postMessageToCanvas(viewId, message);
  }

  @override
  State<ThreeJsCanvasWidget> createState() => _ThreeJsCanvasWidgetState();
}

class _ThreeJsCanvasWidgetState extends State<ThreeJsCanvasWidget> {
  bool _isCanvasReady = false;
  bool _isSceneLoaded = false;

  @override
  void initState() {
    super.initState();
    // 1. Mount the underlying platform canvas view quickly
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _isCanvasReady = true);
      }
    });

    // 2. Safety timeout: fade out loading overlay after 1100ms max if no SCENE_READY event
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted && !_isSceneLoaded) {
        setState(() => _isSceneLoaded = true);
      }
    });
  }

  void _handleMessage(dynamic message) {
    if (message is Map && message['type'] == 'SCENE_READY') {
      if (mounted && !_isSceneLoaded) {
        setState(() => _isSceneLoaded = true);
      }
    }
    widget.onMessage?.call(message);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base dark cosmic backdrop
        Container(
          color: const Color(0xFF020617),
        ),

        // 2. WebGL 3D Canvas
        if (_isCanvasReady)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: widget.ignorePointer,
              child: platform_impl.buildPlatformThreeJsCanvas(
                scenePath: widget.scenePath,
                viewId: widget.viewId,
                onMessageReceived: _handleMessage,
                ignorePointer: widget.ignorePointer,
              ),
            ),
          ),

        // 3. Cinematic Space-Themed Telemetry Loading Overlay (Zero Black Screen)
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _isSceneLoaded,
            child: AnimatedOpacity(
              opacity: _isSceneLoaded ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.15),
                    radius: 1.1,
                    colors: [
                      Color(0xFF0C192E),
                      Color(0xFF040916),
                      Color(0xFF020617),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xDD071224),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x6638BDF8), width: 1.4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x4438BDF8),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                        BoxShadow(color: Colors.black, blurRadius: 16),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Futuristic Dual-Ring Spinner + Radar Satellite
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0x3338BDF8), width: 2),
                              ),
                            ),
                            const SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.8,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                              ),
                            ),
                            const Icon(
                              Icons.satellite_alt_rounded,
                              color: Color(0xFF38BDF8),
                              size: 24,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'جاري تهيئة المركبة الفضائية...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'INITIALIZING TELEMETRY & 3D SYSTEMS...',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'NASA ARTEMIS & MARS EXPLORATION // 2026',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 8.5,
                            fontFamily: 'monospace',
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 4. Optional UI Overlay layered on top of WebGL
        if (widget.overlay != null)
          Positioned.fill(
            child: widget.overlay!,
          ),
      ],
    );
  }
}
