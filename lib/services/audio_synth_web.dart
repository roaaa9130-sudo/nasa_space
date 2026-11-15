// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
import 'package:flutter/services.dart';

class AudioSynthPlatform {
  static js.JsObject? _ctx;

  static js.JsObject? _getCtx() {
    try {
      if (_ctx == null) {
        final audioCtxClass = js.context['AudioContext'] ?? js.context['webkitAudioContext'];
        if (audioCtxClass != null) {
          _ctx = js.JsObject(audioCtxClass as js.JsFunction);
        }
      }
      if (_ctx != null && _ctx!['state'] == 'suspended') {
        _ctx!.callMethod('resume');
      }
    } catch (_) {}
    return _ctx;
  }

  /// Subtle NASA dual-frequency emergency alarm tone (880Hz -> 440Hz pulse)
  static void playAlarmBeep() {
    HapticFeedback.heavyImpact();
    try {
      final ctx = _getCtx();
      if (ctx == null) return;
      final now = ctx['currentTime'] as num;

      final osc = ctx.callMethod('createOscillator') as js.JsObject;
      final gain = ctx.callMethod('createGain') as js.JsObject;

      osc['type'] = 'sawtooth';
      final freq = osc['frequency'] as js.JsObject;
      freq.callMethod('setValueAtTime', [880, now]);
      freq.callMethod('exponentialRampToValueAtTime', [440, now + 0.18]);

      final g = gain['gain'] as js.JsObject;
      g.callMethod('setValueAtTime', [0.12, now]);
      g.callMethod('exponentialRampToValueAtTime', [0.001, now + 0.22]);

      osc.callMethod('connect', [gain]);
      gain.callMethod('connect', [ctx['destination']]);

      osc.callMethod('start', [now]);
      osc.callMethod('stop', [now + 0.22]);
    } catch (_) {}
  }

  /// Futuristic robotic frequency chirp for AI Assistant
  static void playRobotChirp() {
    HapticFeedback.lightImpact();
    try {
      final ctx = _getCtx();
      if (ctx == null) return;
      final now = ctx['currentTime'] as num;

      final osc = ctx.callMethod('createOscillator') as js.JsObject;
      final gain = ctx.callMethod('createGain') as js.JsObject;

      osc['type'] = 'sine';
      final freq = osc['frequency'] as js.JsObject;
      freq.callMethod('setValueAtTime', [600, now]);
      freq.callMethod('exponentialRampToValueAtTime', [1400, now + 0.08]);
      freq.callMethod('exponentialRampToValueAtTime', [950, now + 0.16]);

      final g = gain['gain'] as js.JsObject;
      g.callMethod('setValueAtTime', [0.08, now]);
      g.callMethod('exponentialRampToValueAtTime', [0.001, now + 0.18]);

      osc.callMethod('connect', [gain]);
      gain.callMethod('connect', [ctx['destination']]);

      osc.callMethod('start', [now]);
      osc.callMethod('stop', [now + 0.18]);
    } catch (_) {}
  }

  /// Deep resonance thruster burn rumble for de-orbit and landing
  static void playThrusterRumble() {
    HapticFeedback.mediumImpact();
    try {
      final ctx = _getCtx();
      if (ctx == null) return;
      final now = ctx['currentTime'] as num;

      final osc = ctx.callMethod('createOscillator') as js.JsObject;
      final gain = ctx.callMethod('createGain') as js.JsObject;

      osc['type'] = 'triangle';
      final freq = osc['frequency'] as js.JsObject;
      freq.callMethod('setValueAtTime', [80, now]);
      freq.callMethod('linearRampToValueAtTime', [45, now + 0.6]);

      final g = gain['gain'] as js.JsObject;
      g.callMethod('setValueAtTime', [0.2, now]);
      g.callMethod('exponentialRampToValueAtTime', [0.005, now + 0.6]);

      osc.callMethod('connect', [gain]);
      gain.callMethod('connect', [ctx['destination']]);

      osc.callMethod('start', [now]);
      osc.callMethod('stop', [now + 0.6]);
    } catch (_) {}
  }

  static void playButtonClick() {
    HapticFeedback.selectionClick();
    try {
      final ctx = _getCtx();
      if (ctx == null) return;
      final now = ctx['currentTime'] as num;

      final osc = ctx.callMethod('createOscillator') as js.JsObject;
      final gain = ctx.callMethod('createGain') as js.JsObject;

      osc['type'] = 'sine';
      final freq = osc['frequency'] as js.JsObject;
      freq.callMethod('setValueAtTime', [520, now]);
      freq.callMethod('exponentialRampToValueAtTime', [780, now + 0.05]);

      final g = gain['gain'] as js.JsObject;
      g.callMethod('setValueAtTime', [0.06, now]);
      g.callMethod('exponentialRampToValueAtTime', [0.001, now + 0.06]);

      osc.callMethod('connect', [gain]);
      gain.callMethod('connect', [ctx['destination']]);

      osc.callMethod('start', [now]);
      osc.callMethod('stop', [now + 0.06]);
    } catch (_) {}
  }

  /// Inspiring multi-tone victory/success chime for sample & mission milestones
  static void playVictoryChime() {
    HapticFeedback.heavyImpact();
    try {
      final ctx = _getCtx();
      if (ctx == null) return;
      final now = ctx['currentTime'] as num;

      final notes = [523.25, 659.25, 783.99, 1046.50];
      for (int i = 0; i < notes.length; i++) {
        final noteTime = now + (i * 0.08);
        final osc = ctx.callMethod('createOscillator') as js.JsObject;
        final gain = ctx.callMethod('createGain') as js.JsObject;

        osc['type'] = 'sine';
        final freq = osc['frequency'] as js.JsObject;
        freq.callMethod('setValueAtTime', [notes[i], noteTime]);

        final g = gain['gain'] as js.JsObject;
        g.callMethod('setValueAtTime', [0.10, noteTime]);
        g.callMethod('exponentialRampToValueAtTime', [0.001, noteTime + 0.45]);

        osc.callMethod('connect', [gain]);
        gain.callMethod('connect', [ctx['destination']]);

        osc.callMethod('start', [noteTime]);
        osc.callMethod('stop', [noteTime + 0.45]);
      }
    } catch (_) {}
  }
}
