import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_state_provider.dart';
import '../services/audio_synth_service.dart';
import 'crew_comms_widget.dart';

class HolographicWatchHUDWidget extends ConsumerStatefulWidget {
  final bool initialOpen;
  final ValueChanged<bool>? onToggle;

  const HolographicWatchHUDWidget({
    super.key,
    this.initialOpen = false,
    this.onToggle,
  });

  @override
  ConsumerState<HolographicWatchHUDWidget> createState() => _HolographicWatchHUDWidgetState();
}

class _HolographicWatchHUDWidgetState extends ConsumerState<HolographicWatchHUDWidget>
    with SingleTickerProviderStateMixin {
  late bool _isOpen;
  bool _isCommsModalOpen = false;
  late AnimationController _alarmPulseController;
  Timer? _alarmAudioDebounce;
  bool _hasTriggeredAudio = false;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.initialOpen;
    _alarmPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _alarmPulseController.dispose();
    _alarmAudioDebounce?.cancel();
    super.dispose();
  }

  void _toggle(bool open) {
    AudioSynthService.playButtonClick();
    setState(() {
      _isOpen = open;
      if (!open) _isCommsModalOpen = false;
    });
    widget.onToggle?.call(open);
  }

  void _checkAndPlayAlarm(bool isAlarm) {
    if (isAlarm && !_hasTriggeredAudio) {
      _hasTriggeredAudio = true;
      AudioSynthService.playAlarmBeep();
      _alarmAudioDebounce?.cancel();
      _alarmAudioDebounce = Timer(const Duration(seconds: 4), () {
        _hasTriggeredAudio = false;
      });
    } else if (!isAlarm) {
      _hasTriggeredAudio = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);
    final strings = ref.watch(stringsProvider);
    final telemetry = state.telemetry;
    final isMars = state.planet.name == 'mars';
    final primaryColor = isMars ? const Color(0xFFF97316) : const Color(0xFF38BDF8);
    final isAr = state.language.isArabic;

    // Dynamic Threshold Alarms: Oxygen < 25% or Power < 25% or Radiation > 2.0
    final isO2Critical = telemetry.oxygenLevelPercent < 25.0;
    final isPowerCritical = telemetry.suitPowerPercent < 25.0;
    final isRadHazard = telemetry.radiationMsvPerHour > 2.0;
    final hasActiveAlarm = isO2Critical || isPowerCritical || isRadHazard;
    final hasPendingTask = state.currentTask != null && !state.currentTask!.isCompleted;

    _checkAndPlayAlarm(hasActiveAlarm);

    // If Comms Modal is open, display the full secure crew comms channel
    if (_isCommsModalOpen) {
      return CrewCommsModal(
        onClose: () => setState(() => _isCommsModalOpen = false),
      );
    }

    // 1. Wearable Sci-Fi Hardware Smartwatch Button (Closed State)
    if (!_isOpen) {
      return AnimatedBuilder(
        animation: _alarmPulseController,
        builder: (context, child) {
          final alarmVal = _alarmPulseController.value;
          final borderColor = hasActiveAlarm
              ? Color.lerp(const Color(0xFFEF4444), const Color(0xFF7F1D1D), alarmVal)!
              : (hasPendingTask ? const Color(0xFF10B981) : primaryColor.withValues(alpha: 0.7));
          final glowColor = hasActiveAlarm
              ? const Color(0xFFEF4444)
              : (hasPendingTask ? const Color(0xFF10B981) : primaryColor);

          return InkWell(
            onTap: () => _toggle(true),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF090E17),
                  ],
                ),
                border: Border.all(
                  color: borderColor,
                  width: hasActiveAlarm ? 2.5 : 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: hasActiveAlarm ? 0.4 + 0.4 * alarmVal : 0.25),
                    blurRadius: hasActiveAlarm ? 20 : 12,
                    spreadRadius: hasActiveAlarm ? 2 : 1,
                  ),
                  const BoxShadow(
                    color: Colors.black,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Metallic Watch Bezel Ticks / Screws
                  ...List.generate(4, (index) {
                    final angle = index * (3.14159 / 2);
                    return Transform.rotate(
                      angle: angle,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 3,
                          height: 3,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Center Watch Face Icon
                  Icon(
                    hasActiveAlarm ? Icons.warning_amber_rounded : Icons.watch,
                    color: hasActiveAlarm ? const Color(0xFFEF4444) : (hasPendingTask ? const Color(0xFF10B981) : primaryColor),
                    size: 26,
                  ),

                  // Flashing Red Alert LED Beacon or Green Nominal LED
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasActiveAlarm
                            ? (alarmVal > 0.5 ? const Color(0xFFEF4444) : Colors.transparent)
                            : const Color(0xFF10B981),
                        boxShadow: [
                          BoxShadow(
                            color: hasActiveAlarm ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Small Comms Radio Beacon Indicator
                  if (hasPendingTask)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF10B981),
                        ),
                        child: const Icon(Icons.radio, size: 8, color: Colors.black),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

    // 2. True 3D Holographic Smartwatch Interface (Open State)
    return AnimatedBuilder(
      animation: _alarmPulseController,
      builder: (context, child) {
        final alarmVal = _alarmPulseController.value;
        const holoCyan = Color(0xFF00F0FF);
        final borderColor = hasActiveAlarm
            ? Color.lerp(const Color(0xFFEF4444), const Color(0xFF991B1B), alarmVal)!
            : holoCyan;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Holographic floating terminal panel
            Container(
              width: 320,
              decoration: BoxDecoration(
                color: const Color(0xDD040E1E), // Translucent futuristic HUD
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor.withValues(alpha: 0.85), width: hasActiveAlarm ? 2.2 : 1.6),
                boxShadow: [
                  BoxShadow(
                    color: (hasActiveAlarm ? const Color(0xFFEF4444) : holoCyan)
                        .withValues(alpha: hasActiveAlarm ? 0.35 + 0.25 * alarmVal : 0.3),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                  const BoxShadow(
                    color: Colors.black87,
                    blurRadius: 18,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  foregroundPainter: _HoloScanlinesPainter(
                    hasAlarm: hasActiveAlarm,
                    pulse: alarmVal,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Holographic Top Header with Cyber Corner Accents
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xCC091830),
                          border: Border(bottom: BorderSide(color: borderColor.withValues(alpha: 0.5))),
                        ),
                        child: Row(
                          children: [
                            const Text('◈', style: TextStyle(color: holoCyan, fontSize: 13)),
                            const SizedBox(width: 6),
                            // Smartwatch Title & Astronaut Call Sign
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        strings.smartwatchTitle.toUpperCase(),
                                        style: TextStyle(
                                          color: hasActiveAlarm ? const Color(0xFFEF4444) : holoCyan,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.5,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: hasActiveAlarm
                                              ? (alarmVal > 0.5 ? const Color(0xFFEF4444) : Colors.transparent)
                                              : const Color(0xFF10B981),
                                          boxShadow: [
                                            BoxShadow(
                                              color: hasActiveAlarm ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${state.astronaut.name.toUpperCase()} // ${state.astronaut.callSign} // HOLO-LINK',
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 8.5,
                                      fontFamily: 'monospace',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Close Hologram Button
                            InkWell(
                              onTap: () => _toggle(false),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0x801E293B),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: holoCyan.withValues(alpha: 0.4)),
                                ),
                                child: const Icon(Icons.close, color: holoCyan, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),

                // Flashing Red Alert Banner when threshold is breached
                if (hasActiveAlarm)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2 + 0.25 * alarmVal),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Color(0xFFEF4444), size: 15),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isO2Critical
                                ? strings.criticalAlarmO2
                                : (isPowerCritical ? strings.criticalAlarmPower : strings.criticalAlarmRad),
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Dedicated Crew Comms / Radio Channel Action Button (Requirement 3)
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasPendingTask ? const Color(0xFF10B981) : const Color(0xFF0F1E36),
                      foregroundColor: hasPendingTask ? Colors.black : const Color(0xFF38BDF8),
                      side: BorderSide(
                        color: hasPendingTask ? const Color(0xFF10B981) : const Color(0xFF38BDF8).withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: hasPendingTask ? 8 : 2,
                    ),
                    onPressed: () {
                      AudioSynthService.playRobotChirp();
                      setState(() => _isCommsModalOpen = true);
                    },
                    icon: Icon(Icons.radio, size: 16, color: hasPendingTask ? Colors.black : const Color(0xFF38BDF8)),
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isAr ? 'اللاسلكي المشفر للطاقم (مهام البعثة)' : 'CREW COMMS / RADIO (TASKS)',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.8),
                        ),
                        if (hasPendingTask) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'LINK REQUIRED',
                              style: TextStyle(color: Color(0xFF10B981), fontSize: 7, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Real-time Suit Vitals Console
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // 1. Oxygen (O2)
                      _buildHardwareGauge(
                        icon: Icons.air,
                        label: strings.oxygen,
                        valueText: '${telemetry.oxygenLevelPercent.toStringAsFixed(1)}%',
                        progress: telemetry.oxygenLevelPercent / 100.0,
                        color: isO2Critical ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
                        isAlarm: isO2Critical,
                      ),
                      const SizedBox(height: 8),

                      // 2. Water (H2O)
                      _buildHardwareGauge(
                        icon: Icons.water_drop_outlined,
                        label: strings.water,
                        valueText: '${telemetry.waterLevelPercent.toStringAsFixed(1)}%',
                        progress: telemetry.waterLevelPercent / 100.0,
                        color: const Color(0xFF06B6D4),
                        isAlarm: false,
                      ),
                      const SizedBox(height: 8),

                      // 3. Suit Power (PWR)
                      _buildHardwareGauge(
                        icon: Icons.bolt,
                        label: strings.suitPower,
                        valueText: '${telemetry.suitPowerPercent.toStringAsFixed(1)}%',
                        progress: telemetry.suitPowerPercent / 100.0,
                        color: isPowerCritical ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                        isAlarm: isPowerCritical,
                      ),
                      const SizedBox(height: 10),

                      const Divider(color: Color(0xFF1E293B), height: 1),
                      const SizedBox(height: 10),

                      // 4. Surface Temp & 5. Radiation in split hardware tiles
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              icon: Icons.thermostat,
                              label: strings.surfaceTemp,
                              val: '${telemetry.surfaceTemperatureC.toStringAsFixed(1)}°C',
                              color: const Color(0xFF38BDF8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricTile(
                              icon: Icons.shield,
                              label: strings.radiationFlux,
                              val: '${telemetry.radiationMsvPerHour.toStringAsFixed(2)} mSv',
                              color: isRadHazard ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Interactive Quick-Fix & Replenishment Controls
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionBtn(
                              label: strings.replenishO2,
                              icon: Icons.autorenew,
                              color: const Color(0xFF38BDF8),
                              onTap: () {
                                AudioSynthService.playButtonClick();
                                ref.read(gameStateProvider.notifier).replenishOxygen();
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildActionBtn(
                              label: strings.rechargePower,
                              icon: Icons.battery_charging_full,
                              color: const Color(0xFF10B981),
                              onTap: () {
                                AudioSynthService.playButtonClick();
                                ref.read(gameStateProvider.notifier).replenishPower();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // RCS Thruster Pulse & Simulate Alarm Toggle
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionBtn(
                              label: telemetry.rcsThrustersActive ? strings.thrusterActive : strings.fireThruster,
                              icon: Icons.local_fire_department,
                              color: telemetry.rcsThrustersActive ? Colors.amber : primaryColor,
                              onTap: () {
                                AudioSynthService.playThrusterRumble();
                                ref.read(gameStateProvider.notifier).pulseRcsThrusters();
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildActionBtn(
                              label: strings.testAlarm,
                              icon: Icons.crisis_alert,
                              color: const Color(0xFFEF4444),
                              onTap: () {
                                AudioSynthService.playAlarmBeep();
                                ref.read(gameStateProvider.notifier).simulateLowVitalsAlarm();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      const SizedBox(height: 8),

        // Holographic Projector Wrist Node & Upward Light Emitter
        Row(
          children: [
            InkWell(
              onTap: () => _toggle(false),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xCC091830),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: holoCyan, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: holoCyan.withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radar, size: 14, color: holoCyan),
                    SizedBox(width: 6),
                    Text(
                      'HOLO-EMITTER // ACTIVE',
                      style: TextStyle(
                        color: holoCyan,
                        fontSize: 9,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  },
);
  }

  Widget _buildHardwareGauge({
    required IconData icon,
    required String label,
    required String valueText,
    required double progress,
    required Color color,
    required bool isAlarm,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10.5, fontWeight: FontWeight.w600),
              ),
            ),
            if (isAlarm)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'CRITICAL',
                  style: TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.bold),
                ),
              ),
            Text(
              valueText,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFF1E293B),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String val,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10.5,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoloScanlinesPainter extends CustomPainter {
  final bool hasAlarm;
  final double pulse;

  _HoloScanlinesPainter({required this.hasAlarm, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = (hasAlarm ? const Color(0x18EF4444) : const Color(0x1200F0FF))
      ..strokeWidth = 1.0;

    // Subtle horizontal scanlines
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Holographic corner bracket accents ┌ ┐ └ ┘
    final bracketPaint = Paint()
      ..color = (hasAlarm ? const Color(0xFFEF4444) : const Color(0xFF00F0FF)).withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const bracketSize = 10.0;
    // Top-left
    canvas.drawLine(const Offset(4, 4), const Offset(4 + bracketSize, 4), bracketPaint);
    canvas.drawLine(const Offset(4, 4), const Offset(4, 4 + bracketSize), bracketPaint);
    // Top-right
    canvas.drawLine(Offset(size.width - 4, 4), Offset(size.width - 4 - bracketSize, 4), bracketPaint);
    canvas.drawLine(Offset(size.width - 4, 4), Offset(size.width - 4, 4 + bracketSize), bracketPaint);
    // Bottom-left
    canvas.drawLine(Offset(4, size.height - 4), Offset(4 + bracketSize, size.height - 4), bracketPaint);
    canvas.drawLine(Offset(4, size.height - 4), Offset(4, size.height - 4 - bracketSize), bracketPaint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - 4, size.height - 4), Offset(size.width - 4 - bracketSize, size.height - 4), bracketPaint);
    canvas.drawLine(Offset(size.width - 4, size.height - 4), Offset(size.width - 4, size.height - 4 - bracketSize), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant _HoloScanlinesPainter oldDelegate) => true;
}
