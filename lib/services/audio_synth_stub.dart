import 'package:flutter/services.dart';

class AudioSynthPlatform {
  static void playAlarmBeep() {
    HapticFeedback.heavyImpact();
  }

  static void playRobotChirp() {
    HapticFeedback.lightImpact();
  }

  static void playThrusterRumble() {
    HapticFeedback.mediumImpact();
  }

  static void playButtonClick() {
    HapticFeedback.selectionClick();
  }

  static void playVictoryChime() {
    HapticFeedback.heavyImpact();
  }
}
