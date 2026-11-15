import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/planet_mission.dart';
import '../services/audio_synth_service.dart';

class CinematicDescentWidget extends StatefulWidget {
  final LandingSite site;
  final PlanetType planet;
  final bool isArabic;
  final VoidCallback onDescentComplete;

  const CinematicDescentWidget({
    super.key,
    required this.site,
    required this.planet,
    required this.isArabic,
    required this.onDescentComplete,
  });

  @override
  State<CinematicDescentWidget> createState() => _CinematicDescentWidgetState();
}

class _CinematicDescentWidgetState extends State<CinematicDescentWidget>
    with TickerProviderStateMixin {
  int _phase = 0; // 0: Boarding, 1: De-orbit Burn, 2: Terminal Braking, 3: Touchdown
  double _altitudeKm = 384.0;
  double _velocityKmh = 24100.0;
  Timer? _sequenceTimer;
  Timer? _telemetryTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _altitudeKm = widget.planet == PlanetType.mars ? 384.0 : 112.0;
    _velocityKmh = widget.planet == PlanetType.mars ? 24100.0 : 5880.0;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _startSequence();
  }

  void _startSequence() {
    AudioSynthService.playThrusterRumble();

    // Altitude & Velocity rapid deceleration ticker
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) return;
      setState(() {
        if (_altitudeKm > 0.05) {
          _altitudeKm = (_altitudeKm * 0.92) - 0.5;
          if (_altitudeKm < 0) _altitudeKm = 0;
        }
        if (_velocityKmh > 12.0) {
          _velocityKmh = (_velocityKmh * 0.93) - 20;
          if (_velocityKmh < 0) _velocityKmh = 0;
        }
      });
    });

    // Phase progression
    // Phase 0: Boarding (0 -> 1.8s)
    // Phase 1: De-orbit burn (1.8s -> 3.6s)
    // Phase 2: Terminal braking (3.6s -> 5.2s)
    // Phase 3: Touchdown (5.2s -> 6.4s)
    _sequenceTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      AudioSynthService.playThrusterRumble();
      setState(() => _phase = 1);

      _sequenceTimer = Timer(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        AudioSynthService.playThrusterRumble();
        setState(() => _phase = 2);

        _sequenceTimer = Timer(const Duration(milliseconds: 1600), () {
          if (!mounted) return;
          AudioSynthService.playRobotChirp();
          setState(() => _phase = 3);

          _sequenceTimer = Timer(const Duration(milliseconds: 1200), () {
            _finish();
          });
        });
      });
    });
  }

  void _finish() {
    _sequenceTimer?.cancel();
    _telemetryTimer?.cancel();
    widget.onDescentComplete();
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    _telemetryTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMars = widget.planet == PlanetType.mars;
    final primaryColor = isMars ? const Color(0xFFF97316) : const Color(0xFF38BDF8);
    final siteName = widget.isArabic ? widget.site.nameArabic : widget.site.name;

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: Colors.black.withValues(alpha: 0.94),
          child: SafeArea(
            child: Stack(
              children: [
                // Sci-Fi Starfield & Plasma Speed Lines
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DescentPlasmaPainter(
                      progress: _phase / 3.0,
                      pulse: _pulseController.value,
                      primaryColor: primaryColor,
                    ),
                  ),
                ),

                // Top Skip Button
                Positioned(
                  top: 16,
                  right: widget.isArabic ? null : 20,
                  left: widget.isArabic ? 20 : null,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.8),
                    ),
                    onPressed: _finish,
                    icon: const Icon(Icons.fast_forward, size: 16),
                    label: Text(
                      widget.isArabic ? 'تخطي المشهد' : 'SKIP DESCENT',
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Center Content: Descent Trajectory & Boarding Visuals
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 540),
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Phase Step Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStepNode(0, 'BOARDING', Icons.meeting_room, primaryColor),
                            _buildStepConnector(0, primaryColor),
                            _buildStepNode(1, 'DE-ORBIT', Icons.flight_takeoff, primaryColor),
                            _buildStepConnector(1, primaryColor),
                            _buildStepNode(2, 'BRAKING', Icons.speed, primaryColor),
                            _buildStepConnector(2, primaryColor),
                            _buildStepNode(3, 'TOUCHDOWN', Icons.flight_land, primaryColor),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Phase Animated Icon & Graphic
                        _buildPhaseVisual(primaryColor),
                        const SizedBox(height: 24),

                        // Phase Title
                        Text(
                          _getPhaseTitle().toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Target Site & Coordinates
                        Text(
                          '${widget.isArabic ? 'الهدف المجدول:' : 'DESTINATION:'} $siteName // ${widget.site.coordinateString}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Real-Time Telemetry Counters (Altitude & Velocity)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF080F1E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    widget.isArabic ? 'الارتفاع المتبقي' : 'ALTITUDE',
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontFamily: 'monospace'),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_altitudeKm.toStringAsFixed(1)} KM',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 32, color: const Color(0xFF1E293B)),
                              Column(
                                children: [
                                  Text(
                                    widget.isArabic ? 'السرعة المتجهة' : 'VELOCITY',
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontFamily: 'monospace'),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_velocityKmh.toStringAsFixed(0)} KM/H',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseVisual(Color primaryColor) {
    switch (_phase) {
      case 0:
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2),
                color: primaryColor.withValues(alpha: 0.15),
              ),
              child: Icon(Icons.person_pin, color: primaryColor, size: 44),
            ),
          ],
        );
      case 1:
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 2),
                color: Colors.amber.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.local_fire_department, color: Colors.amber, size: 44),
            ),
          ],
        );
      case 2:
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEF4444), width: 2),
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.blur_on, color: Color(0xFFEF4444), size: 44),
            ),
          ],
        );
      default:
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF10B981), width: 2),
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 44),
            ),
          ],
        );
    }
  }

  String _getPhaseTitle() {
    switch (_phase) {
      case 0:
        return widget.isArabic
            ? 'صعود رائد الفضاء وإغلاق غرفة الضغط'
            : 'Astronaut Boarding // Airlock Hatch Sealed';
      case 1:
        return widget.isArabic
            ? 'اشتعال محركات الدفع وتعديل مسار الدخول'
            : 'Retro-Burn Initiated // De-orbit Trajectory';
      case 2:
        return widget.isArabic
            ? 'دخول الغلاف الجوي والكبح النهائي النشط'
            : 'Terminal Braking // Retro-Propulsion Active';
      default:
        return widget.isArabic
            ? 'تم الهبوط بنجاح! جاري نشر مركبة الاستكشاف'
            : 'Touchdown Confirmed! Deploying Surface Rover';
    }
  }

  Widget _buildStepNode(int step, String label, IconData icon, Color primaryColor) {
    final isDone = _phase > step;
    final isCurrent = _phase == step;
    final color = isDone
        ? const Color(0xFF10B981)
        : (isCurrent ? primaryColor : const Color(0xFF475569));

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: isCurrent ? 2.0 : 1.2),
          ),
          child: Icon(isDone ? Icons.check : icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 7.5,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step, Color primaryColor) {
    final isDone = _phase > step;
    return Container(
      width: 28,
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: isDone ? const Color(0xFF10B981) : const Color(0xFF334155),
    );
  }
}

class _DescentPlasmaPainter extends CustomPainter {
  final double progress;
  final double pulse;
  final Color primaryColor;

  _DescentPlasmaPainter({
    required this.progress,
    required this.pulse,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.08 + 0.12 * pulse)
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);

    // Radiating warp / plasma lines
    for (int i = 0; i < 24; i++) {
      final angle = (i * 3.14159 * 2) / 24;
      final startDist = 60.0 + 30.0 * pulse;
      final endDist = size.width * (0.4 + 0.3 * progress);

      final p1 = Offset(center.dx + math.cos(angle) * startDist, center.dy + math.sin(angle) * startDist);
      final p2 = Offset(center.dx + math.cos(angle) * endDist, center.dy + math.sin(angle) * endDist);

      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DescentPlasmaPainter oldDelegate) => true;
}
