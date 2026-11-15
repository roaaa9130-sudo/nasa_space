import 'package:flutter/material.dart';

Widget buildPlatformThreeJsCanvas({
  required String scenePath,
  required String viewId,
  required Function(dynamic message) onMessageReceived,
  bool ignorePointer = false,
}) {
  Widget content = Container(
    color: const Color(0xFF030712),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.rocket_launch, color: Color(0xFF38BDF8), size: 48),
          const SizedBox(height: 16),
          const Text(
            'NASA 3D WebGL Engine (Standalone Mode)',
            style: TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Scene: $scenePath',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    ),
  );
  return ignorePointer ? IgnorePointer(child: content) : content;
}

void postMessageToCanvas(String viewId, Map<String, dynamic> message) {
  // Non-web fallback
}
