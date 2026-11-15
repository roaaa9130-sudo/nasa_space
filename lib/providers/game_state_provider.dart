import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/crew_model.dart';
import '../models/planet_mission.dart';
import '../l10n/app_localizations.dart';
import '../services/audio_synth_service.dart';

enum HazardType {
  none,
  oxygenLeak,
  solarFlare,
  dustStorm,
  powerGridFailure;

  String title(bool isAr) => switch (this) {
    HazardType.none => '',
    HazardType.oxygenLeak => isAr ? 'تسريب حرج في منظم الأكسجين!' : 'CRITICAL O2 REGULATOR LEAK!',
    HazardType.solarFlare => isAr ? 'عاصفة إشعاع شمسي مكثفة!' : 'SOLAR RADIATION STORM INCOMING!',
    HazardType.dustStorm => isAr ? 'عاصفة غبارية كهرومغناطيسية!' : 'ELECTROSTATIC DUST VORTEX!',
    HazardType.powerGridFailure => isAr ? 'هبوط حرج في خلايا الطاقة!' : 'SUIT POWER MATRIX ANOMALY!',
  };

  String description(bool isAr) => switch (this) {
    HazardType.none => '',
    HazardType.oxygenLeak => isAr
        ? 'انخفاض سريع في مخزون الأكسجين! أصلح الصمام فوراً للحفاظ على استقرار التنفس.'
        : 'Oxygen levels venting rapidly! Seal the regulator valve immediately.',
    HazardType.solarFlare => isAr
        ? 'ارتفاع مستويات الإشعاع الكوني! انشر التدريع الكهرومغناطيسي لحماية أنظمة البذلة.'
        : 'Cosmic radiation flux spiking! Deploy electromagnetic shields to protect vitals.',
    HazardType.dustStorm => isAr
        ? 'حبيبات الثرى الكهرومغناطيسية تحجب الألواح الشمسية وأجهزة الاستشعار والملاحة!'
        : 'Electrostatic regolith particles blinding suit optical sensors and solar cells!',
    HazardType.powerGridFailure => isAr
        ? 'حمل زائد في الدوائر الإلكترونية المساعدة! أعد تشغيل مصفوفة الطاقة لتفادي الإغلاق.'
        : 'Overload in auxiliary circuits! Reboot the suit power core to avoid emergency shutdown.',
  };

  String repairLabel(bool isAr) => switch (this) {
    HazardType.none => '',
    HazardType.oxygenLeak => isAr ? 'إصلاح صمام الأكسجين (+50 نقطة)' : 'REPAIR O2 VALVE (+50 XP)',
    HazardType.solarFlare => isAr ? 'نشر درع الإشعاع (+50 نقطة)' : 'DEPLOY RADIATION SHIELD (+50 XP)',
    HazardType.dustStorm => isAr ? 'تنظيف الألواح والمستشعرات (+50 نقطة)' : 'PURGE OPTICAL SENSORS (+50 XP)',
    HazardType.powerGridFailure => isAr ? 'إعادة تشغيل الطاقة (+50 نقطة)' : 'REBOOT POWER MATRIX (+50 XP)',
  };

  IconData get icon => switch (this) {
    HazardType.none => Icons.check_circle_outline,
    HazardType.oxygenLeak => Icons.air_rounded,
    HazardType.solarFlare => Icons.solar_power_rounded,
    HazardType.dustStorm => Icons.cyclone_rounded,
    HazardType.powerGridFailure => Icons.battery_alert_rounded,
  };
}

class GameState {
  final PlanetType planet;
  final LandingSite selectedSite;
  final TelemetryData telemetry;
  final AppLanguage language;
  final MissionPhase missionPhase;
  final bool isGridActive;
  final bool isAutoRotateActive;
  final bool isAudioActive;
  final String activeScene; // 'orbit_scene.html' or 'game_scene.html'
  final int explorationPoints;
  final double roverSpeedKmh;
  final double roverHeadingDeg;
  final AstronautProfile astronaut;
  final List<MissionTask> tasks;
  final int currentTaskIndex;
  final int samplesCollected;
  final double distanceToTarget;
  final double astronautX;
  final double astronautZ;
  final HazardType activeHazard;

  const GameState({
    required this.planet,
    required this.selectedSite,
    required this.telemetry,
    required this.language,
    required this.missionPhase,
    required this.isGridActive,
    required this.isAutoRotateActive,
    required this.isAudioActive,
    required this.activeScene,
    required this.explorationPoints,
    required this.roverSpeedKmh,
    required this.roverHeadingDeg,
    required this.astronaut,
    required this.tasks,
    required this.currentTaskIndex,
    this.samplesCollected = 0,
    this.distanceToTarget = 32.4,
    this.astronautX = 0.0,
    this.astronautZ = 0.0,
    this.activeHazard = HazardType.none,
  });

  MissionTask? get currentTask => (tasks.isNotEmpty && currentTaskIndex < tasks.length)
      ? tasks[currentTaskIndex]
      : (tasks.isNotEmpty ? tasks.last : null);

  GameState copyWith({
    PlanetType? planet,
    LandingSite? selectedSite,
    TelemetryData? telemetry,
    AppLanguage? language,
    MissionPhase? missionPhase,
    bool? isGridActive,
    bool? isAutoRotateActive,
    bool? isAudioActive,
    String? activeScene,
    int? explorationPoints,
    double? roverSpeedKmh,
    double? roverHeadingDeg,
    AstronautProfile? astronaut,
    List<MissionTask>? tasks,
    int? currentTaskIndex,
    int? samplesCollected,
    double? distanceToTarget,
    double? astronautX,
    double? astronautZ,
    HazardType? activeHazard,
  }) {
    return GameState(
      planet: planet ?? this.planet,
      selectedSite: selectedSite ?? this.selectedSite,
      telemetry: telemetry ?? this.telemetry,
      language: language ?? this.language,
      missionPhase: missionPhase ?? this.missionPhase,
      isGridActive: isGridActive ?? this.isGridActive,
      isAutoRotateActive: isAutoRotateActive ?? this.isAutoRotateActive,
      isAudioActive: isAudioActive ?? this.isAudioActive,
      activeScene: activeScene ?? this.activeScene,
      explorationPoints: explorationPoints ?? this.explorationPoints,
      roverSpeedKmh: roverSpeedKmh ?? this.roverSpeedKmh,
      roverHeadingDeg: roverHeadingDeg ?? this.roverHeadingDeg,
      astronaut: astronaut ?? this.astronaut,
      tasks: tasks ?? this.tasks,
      currentTaskIndex: currentTaskIndex ?? this.currentTaskIndex,
      samplesCollected: samplesCollected ?? this.samplesCollected,
      distanceToTarget: distanceToTarget ?? this.distanceToTarget,
      astronautX: astronautX ?? this.astronautX,
      astronautZ: astronautZ ?? this.astronautZ,
      activeHazard: activeHazard ?? this.activeHazard,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  Timer? _telemetryTicker;
  Box? _settingsBox;

  GameNotifier()
      : super(GameState(
          planet: PlanetType.mars,
          selectedSite: PlanetaryCatalog.marsSites.first,
          telemetry: TelemetryData.defaultForPlanet(PlanetType.mars),
          language: AppLanguage.english,
          missionPhase: MissionPhase.orbitalRecon,
          isGridActive: true,
          isAutoRotateActive: true,
          isAudioActive: false,
          activeScene: 'orbit_scene.html',
          explorationPoints: 0,
          roverSpeedKmh: 0.0,
          roverHeadingDeg: 84.0,
          astronaut: const AstronautProfile(),
          tasks: MissionTask.getTasksFor(PlanetType.mars, PlanetaryCatalog.marsSites.first.name),
          currentTaskIndex: 0,
        )) {
    debugPrint('🪐 [GAME NOTIFIER] GameNotifier instance initialized with initial baseline state.');
    _initHiveAndLoadSettings();
    _startTelemetrySimulation();
  }

  void _initHiveAndLoadSettings() {
    debugPrint('📦 [GAME STATE] Initializing Hive and checking storage state...');
    try {
      bool isOpen = false;
      try {
        isOpen = Hive.isBoxOpen('nasa_space_settings');
      } catch (_) {
        isOpen = false;
      }

      if (isOpen) {
        debugPrint('✅ [GAME STATE] "nasa_space_settings" box is already open. Reading settings...');
        _settingsBox = Hive.box('nasa_space_settings');
        _loadSavedSettings();
      } else {
        debugPrint('⏳ [GAME STATE] "nasa_space_settings" box not open; attempting async open...');
        Hive.openBox('nasa_space_settings')
            .timeout(const Duration(milliseconds: 1500))
            .then((box) {
          debugPrint('✅ [GAME STATE] Box opened asynchronously. Loading saved settings...');
          _settingsBox = box;
          _loadSavedSettings();
        }).catchError((e) {
          debugPrint('⚠️ [GAME STATE] Hive.openBox async fallback: $e. Using default mission state.');
        });
      }
    } catch (e, stack) {
      debugPrint('⚠️ [GAME STATE] Hive access error: $e. Using fallback defaults.');
      debugPrint('$stack');
    }
  }

  void _loadSavedSettings() {
    if (_settingsBox == null) {
      debugPrint('ℹ️ [GAME STATE] Settings box is null; maintaining default state.');
      return;
    }
    try {
      final langCode = _settingsBox?.get('language', defaultValue: 'en') as String?;
      final savedPlanet = _settingsBox?.get('planet', defaultValue: 'mars') as String?;
      final points = _settingsBox?.get('points', defaultValue: 0) as int?;
      final samples = _settingsBox?.get('samples_collected', defaultValue: 0) as int?;
      final savedProfile = _settingsBox?.get('astronaut_profile');

      debugPrint('⚙️ [GAME STATE] Loaded: lang=$langCode, planet=$savedPlanet, points=$points, samples=$samples');

      final planet = savedPlanet == 'moon' ? PlanetType.moon : PlanetType.mars;
      final lang = langCode == 'ar' ? AppLanguage.arabic : AppLanguage.english;
      final sites = PlanetaryCatalog.getSitesFor(planet);
      final selectedSite = sites.first;

      AstronautProfile astronaut = const AstronautProfile();
      if (savedProfile is Map) {
        astronaut = AstronautProfile.fromJson(savedProfile);
      }

      state = state.copyWith(
        planet: planet,
        language: lang,
        selectedSite: selectedSite,
        telemetry: TelemetryData.defaultForPlanet(planet),
        explorationPoints: points ?? 0,
        samplesCollected: samples ?? 0,
        astronaut: astronaut,
        tasks: MissionTask.getTasksFor(planet, selectedSite.name),
        currentTaskIndex: 0,
      );
      debugPrint('✅ [GAME STATE] GameState successfully synchronized with storage.');
    } catch (e, stack) {
      debugPrint('⚠️ [GAME STATE] Error parsing saved settings: $e; keeping defaults.');
      debugPrint('$stack');
    }
  }

  int _telemetryTickCount = 0;

  void _startTelemetrySimulation() {
    _telemetryTicker = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (!mounted) return;
      _telemetryTickCount++;
      final current = state.telemetry;

      if (state.missionPhase == MissionPhase.surfaceExploration) {
        // Dynamic Surface Resource Depletion & Environmental Hazards
        double o2Decay = 0.08;
        double powerDecay = 0.06;

        if (state.activeHazard == HazardType.oxygenLeak) {
          o2Decay = 0.45;
        } else if (state.activeHazard == HazardType.powerGridFailure) {
          powerDecay = 0.40;
        } else if (state.activeHazard == HazardType.dustStorm) {
          powerDecay = 0.22;
        }

        final newO2 = (current.oxygenLevelPercent - o2Decay).clamp(5.0, 100.0);
        final newPower = (current.suitPowerPercent - powerDecay).clamp(5.0, 100.0);

        HazardType nextHazard = state.activeHazard;

        // Periodic random environmental hazard every ~35 ticks (approx 42 seconds)
        if (state.activeHazard == HazardType.none && _telemetryTickCount % 35 == 0) {
          final hazards = [
            HazardType.oxygenLeak,
            HazardType.solarFlare,
            HazardType.dustStorm,
            HazardType.powerGridFailure,
          ];
          nextHazard = hazards[(_telemetryTickCount ~/ 35) % hazards.length];
          AudioSynthService.playAlarmBeep();
        } else if (state.activeHazard == HazardType.none) {
          // Low vitals hazard trigger
          if (newO2 < 30.0) {
            nextHazard = HazardType.oxygenLeak;
            AudioSynthService.playAlarmBeep();
          } else if (newPower < 30.0) {
            nextHazard = HazardType.powerGridFailure;
            AudioSynthService.playAlarmBeep();
          }
        }

        state = state.copyWith(
          activeHazard: nextHazard,
          telemetry: current.copyWith(
            oxygenLevelPercent: newO2,
            suitPowerPercent: newPower,
          ),
        );
      } else {
        // Realistic slight orbital perturbations
        final speedJitter = (DateTime.now().millisecond % 5 - 2) * 0.4;
        final altJitter = (DateTime.now().millisecond % 3 - 1) * 0.05;
        final oxygenDecay = current.oxygenLevelPercent > 10.0 ? current.oxygenLevelPercent - 0.005 : 10.0;

        state = state.copyWith(
          telemetry: current.copyWith(
            velocityKmh: (current.velocityKmh + speedJitter).clamp(1000.0, 30000.0),
            altitudeKm: (current.altitudeKm + altJitter).clamp(10.0, 500.0),
            oxygenLevelPercent: oxygenDecay,
          ),
        );
      }
    });
  }

  void setAstronautProfile(AstronautProfile profile) {
    state = state.copyWith(astronaut: profile);
    _settingsBox?.put('astronaut_profile', profile.toJson());
  }

  void setPlanet(PlanetType newPlanet) {
    final sites = PlanetaryCatalog.getSitesFor(newPlanet);
    final newSite = sites.first;
    state = state.copyWith(
      planet: newPlanet,
      selectedSite: newSite,
      telemetry: TelemetryData.defaultForPlanet(newPlanet),
      tasks: MissionTask.getTasksFor(newPlanet, newSite.name),
      currentTaskIndex: 0,
    );
    _settingsBox?.put('planet', newPlanet.name);
  }

  void selectSite(LandingSite site) {
    state = state.copyWith(
      selectedSite: site,
      tasks: MissionTask.getTasksFor(state.planet, site.name),
      currentTaskIndex: 0,
    );
  }

  void selectTaskIndex(int index) {
    if (index >= 0 && index < state.tasks.length) {
      state = state.copyWith(currentTaskIndex: index);
    }
  }

  bool completeMissionTask(String contactId) {
    final cur = state.currentTask;
    if (cur == null || cur.isCompleted) return false;
    if (cur.requiredContactId == contactId) {
      final updatedList = List<MissionTask>.from(state.tasks);
      updatedList[state.currentTaskIndex] = cur.copyWith(isCompleted: true);
      final nextIndex = (state.currentTaskIndex + 1 < updatedList.length)
          ? state.currentTaskIndex + 1
          : state.currentTaskIndex;

      state = state.copyWith(
        tasks: updatedList,
        currentTaskIndex: nextIndex,
        explorationPoints: state.explorationPoints + cur.xpReward,
      );
      _settingsBox?.put('points', state.explorationPoints);
      return true;
    }
    return false;
  }

  void setLanguage(AppLanguage language) {
    state = state.copyWith(language: language);
    _settingsBox?.put('language', language.code);
  }

  void toggleLanguage() {
    final next = state.language == AppLanguage.english ? AppLanguage.arabic : AppLanguage.english;
    setLanguage(next);
  }

  void setMissionPhase(MissionPhase phase) {
    state = state.copyWith(missionPhase: phase);
  }

  void setScene(String scene) {
    state = state.copyWith(activeScene: scene);
  }

  void toggleGrid() {
    state = state.copyWith(isGridActive: !state.isGridActive);
  }

  void toggleAutoRotate() {
    state = state.copyWith(isAutoRotateActive: !state.isAutoRotateActive);
  }

  void toggleAudio() {
    state = state.copyWith(isAudioActive: !state.isAudioActive);
  }

  void pulseRcsThrusters() {
    if (state.telemetry.fuelLevelPercent <= 0) return;
    final newFuel = (state.telemetry.fuelLevelPercent - 0.8).clamp(0.0, 100.0);
    state = state.copyWith(
      telemetry: state.telemetry.copyWith(
        rcsThrustersActive: true,
        fuelLevelPercent: newFuel,
        pitchDeg: state.telemetry.pitchDeg + 1.2,
      ),
    );

    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      state = state.copyWith(
        telemetry: state.telemetry.copyWith(rcsThrustersActive: false),
      );
    });
  }

  void updateRoverTelemetry(double speedKmh, double headingDeg) {
    state = state.copyWith(
      roverSpeedKmh: speedKmh,
      roverHeadingDeg: headingDeg,
    );
  }

  void updateAstronautTelemetry({
    required double x,
    required double z,
    required double distanceToTarget,
    required double speed,
    required double heading,
  }) {
    state = state.copyWith(
      astronautX: x,
      astronautZ: z,
      distanceToTarget: distanceToTarget,
      roverSpeedKmh: speed,
      roverHeadingDeg: heading,
      // Total score remains strictly static during movement
    );
  }

  bool collectSample() {
    // Only increment when a sample is collected (+50 points once)
    final nextSamples = state.samplesCollected + 1;
    final nextPoints = state.explorationPoints + 50;
    state = state.copyWith(
      samplesCollected: nextSamples,
      explorationPoints: nextPoints,
    );
    _settingsBox?.put('samples_collected', nextSamples);
    _settingsBox?.put('points', nextPoints);
    return true;
  }

  void addScore(int points) {
    final nextPoints = state.explorationPoints + points;
    state = state.copyWith(explorationPoints: nextPoints);
    _settingsBox?.put('points', nextPoints);
  }

  void triggerHazard(HazardType type) {
    state = state.copyWith(activeHazard: type);
    AudioSynthService.playAlarmBeep();
  }

  void clearHazard() {
    state = state.copyWith(activeHazard: HazardType.none);
  }

  void repairActiveHazard() {
    final nextPoints = state.explorationPoints + 50;
    state = state.copyWith(
      activeHazard: HazardType.none,
      explorationPoints: nextPoints,
      telemetry: state.telemetry.copyWith(
        oxygenLevelPercent: 98.5,
        suitPowerPercent: 99.0,
      ),
    );
    _settingsBox?.put('points', nextPoints);
    AudioSynthService.playVictoryChime();
  }

  void replenishOxygen() {
    state = state.copyWith(
      telemetry: state.telemetry.copyWith(oxygenLevelPercent: 98.5),
    );
  }

  void replenishPower() {
    state = state.copyWith(
      telemetry: state.telemetry.copyWith(suitPowerPercent: 99.0),
    );
  }

  void simulateLowVitalsAlarm() {
    state = state.copyWith(
      telemetry: state.telemetry.copyWith(
        oxygenLevelPercent: 18.4,
        suitPowerPercent: 22.1,
      ),
    );
  }

  @override
  void dispose() {
    _telemetryTicker?.cancel();
    super.dispose();
  }
}

final gameStateProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

final stringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(gameStateProvider.select((s) => s.language));
  return AppStrings(lang);
});
