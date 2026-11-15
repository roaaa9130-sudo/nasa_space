import 'audio_synth_stub.dart'
    if (dart.library.html) 'audio_synth_web.dart' as platform_synth;

class AudioSynthService {
  static void playAlarmBeep() => platform_synth.AudioSynthPlatform.playAlarmBeep();
  static void playRobotChirp() => platform_synth.AudioSynthPlatform.playRobotChirp();
  static void playThrusterRumble() => platform_synth.AudioSynthPlatform.playThrusterRumble();
  static void playButtonClick() => platform_synth.AudioSynthPlatform.playButtonClick();
  static void playVictoryChime() => platform_synth.AudioSynthPlatform.playVictoryChime();
}
