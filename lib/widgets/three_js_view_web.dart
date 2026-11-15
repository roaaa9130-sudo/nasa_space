// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final Map<String, html.IFrameElement> _registeredIframes = {};
final Set<String> _registeredViewTypes = {};

Widget buildPlatformThreeJsCanvas({
  required String scenePath,
  required String viewId,
  required Function(dynamic message) onMessageReceived,
  bool ignorePointer = false,
}) {
  final uniqueKey = 'nasa-threejs-$viewId';

  if (!_registeredViewTypes.contains(uniqueKey)) {
    final iframe = html.IFrameElement()
      ..id = uniqueKey
      ..src = scenePath
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = '#030712'
      ..style.pointerEvents = ignorePointer ? 'none' : 'auto'
      ..allow = 'accelerometer; gyroscope; autoplay; fullscreen';

    _registeredIframes[uniqueKey] = iframe;

    ui_web.platformViewRegistry.registerViewFactory(
      uniqueKey,
      (int id) => iframe,
    );
    _registeredViewTypes.add(uniqueKey);

    // Global listener for postMessage events from Three.js iframe
    html.window.addEventListener('message', (event) {
      if (event is html.MessageEvent && event.data != null) {
        try {
          final raw = event.data;
          if (raw is String) {
            final parsed = jsonDecode(raw);
            onMessageReceived(parsed);
          } else if (raw is Map) {
            onMessageReceived(raw);
          }
        } catch (_) {}
      }
    });
  } else {
    // If iframe exists, make sure src matches current scene
    final iframe = _registeredIframes[uniqueKey];
    if (iframe != null) {
      if (!iframe.src!.endsWith(scenePath)) {
        iframe.src = scenePath;
      }
      iframe.style.pointerEvents = ignorePointer ? 'none' : 'auto';
    }
  }

  return HtmlElementView(
    key: ValueKey(uniqueKey),
    viewType: uniqueKey,
  );
}

void postMessageToCanvas(String viewId, Map<String, dynamic> message) {
  final uniqueKey = 'nasa-threejs-$viewId';
  final iframe = _registeredIframes[uniqueKey];
  if (iframe != null && iframe.contentWindow != null) {
    iframe.contentWindow!.postMessage(jsonEncode(message), '*');
  }
}
