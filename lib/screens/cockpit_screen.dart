import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planet_mission.dart';
import '../providers/game_state_provider.dart';
import '../services/audio_synth_service.dart';
import '../services/navigation_helper.dart';
import '../widgets/ai_companion_widget.dart';
import '../widgets/holographic_hud_widget.dart';
import '../widgets/sci_fi_back_button.dart';
import '../widgets/three_js_canvas_widget.dart';
import 'mission_selection_screen.dart';

class CockpitScreen extends ConsumerStatefulWidget {
  final bool initialSurfaceMode;

  const CockpitScreen({
    super.key,
    this.initialSurfaceMode = false,
  });

  @override
  ConsumerState<CockpitScreen> createState() => _CockpitScreenState();
}

class _CockpitScreenState extends ConsumerState<CockpitScreen> {
  late bool _isSurfaceMode;
  bool _isSystemMenuOpen = false;
  bool _isObjectivesMenuOpen = false;
  final FocusNode _keyboardFocusNode = FocusNode();
  Offset _joystickDelta = Offset.zero;
  static const double _joystickRadius = 42.0;

  bool _hasAutoShownInZone = false;
  double _targetX = 26.0;
  double _targetZ = -32.0;

  @override
  void initState() {
    super.initState();
    _isSurfaceMode = widget.initialSurfaceMode;

    if (_isSurfaceMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasAutoShownInZone) {
          _hasAutoShownInZone = true;
          final state = ref.read(gameStateProvider);
          final isMars = state.planet == PlanetType.mars;
          final primaryColor = isMars ? const Color(0xFFF97316) : const Color(0xFF38BDF8);
          _showInZoneMissionDialog(context, state, state.language.isArabic, primaryColor);
        }
      });
    }
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _sendDirection(String viewId, String direction, bool active) {
    ThreeJsCanvasWidget.sendMessage(viewId, {
      'action': 'DRIVE_COMMAND',
      'direction': direction,
      'active': active,
    });
  }

  void _sendJoystick(String viewId, double dx, double dy) {
    ThreeJsCanvasWidget.sendMessage(viewId, {
      'action': 'JOYSTICK_MOVE',
      'dx': dx,
      'dy': dy,
    });
  }

  void _triggerJump(String viewId) {
    AudioSynthService.playThrusterRumble();
    ThreeJsCanvasWidget.sendMessage(viewId, {'action': 'JUMP'});
  }

  void _collectSampleAction(String viewId, bool isAr) {
    AudioSynthService.playVictoryChime();
    ref.read(gameStateProvider.notifier).collectSample();
    ThreeJsCanvasWidget.sendMessage(viewId, {'action': 'COLLECT_SAMPLE'});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isAr
                    ? 'تم جمع العينة الفضائية بنجاح (+50 نقطة)!'
                    : 'Scientific Sample Collected Successfully (+50 XP)!',
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInZoneMissionDialog(BuildContext context, GameState state, bool isAr, Color primaryColor) {
    AudioSynthService.playButtonClick();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Directionality(
          textDirection: state.language.textDirection,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520, maxHeight: 580),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF040D1A).withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                  const BoxShadow(color: Colors.black, blurRadius: 20),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withValues(alpha: 0.15),
                          border: Border.all(color: primaryColor),
                        ),
                        child: Icon(Icons.explore_rounded, color: primaryColor, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? state.selectedSite.nameArabic : state.selectedSite.name,
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              isAr ? 'المهام والعمليات الميدانية للمنطقة' : 'REGIONAL IN-ZONE EXPEDITION MISSIONS',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          AudioSynthService.playButtonClick();
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.close_rounded),
                        color: const Color(0xFF64748B),
                        tooltip: isAr ? 'إغلاق' : 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF1E293B)),
                  const SizedBox(height: 10),
                  Text(
                    isAr
                        ? 'حدد المهمة الاستكشافية لتوجيه مسار الملاحة ونقاط الأهداف:'
                        : 'Select a planetary mission to lock coordinates and active target beacon:',
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  // Missions list
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final task = state.tasks[index];
                        final isActive = state.currentTaskIndex == index;
                        final isCompleted = task.isCompleted;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isActive
                                ? primaryColor.withValues(alpha: 0.12)
                                : const Color(0xFF071224),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isActive
                                  ? primaryColor
                                  : (isCompleted ? const Color(0xFF10B981) : const Color(0xFF1E293B)),
                              width: isActive ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCompleted
                                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                      : (isActive ? primaryColor.withValues(alpha: 0.2) : const Color(0xFF1E293B)),
                                ),
                                child: Center(
                                  child: isCompleted
                                      ? const Icon(Icons.check, color: Color(0xFF10B981), size: 18)
                                      : Text(
                                          '0${index + 1}',
                                          style: TextStyle(
                                            color: isActive ? primaryColor : const Color(0xFF94A3B8),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            isAr ? task.titleAr : task.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '+${task.xpReward} XP',
                                            style: const TextStyle(
                                              color: Color(0xFFF59E0B),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isAr ? task.descriptionAr : task.description,
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 10,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isActive ? primaryColor : const Color(0xFF1E293B),
                                  foregroundColor: isActive ? Colors.black : Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  AudioSynthService.playButtonClick();
                                  ref.read(gameStateProvider.notifier).selectTaskIndex(index);
                                  Navigator.pop(ctx);
                                },
                                child: Text(
                                  isActive
                                      ? (isAr ? 'نشطة' : 'ACTIVE')
                                      : (isAr ? 'تفعيل' : 'SELECT'),
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDebriefingDialog(BuildContext context, GameState state, bool isAr, Color primaryColor) {
    AudioSynthService.playButtonClick();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Directionality(
          textDirection: state.language.textDirection,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF040D1A).withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                  const BoxShadow(
                    color: Colors.black,
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header: NASA Mission Debrief Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          border: Border.all(color: const Color(0xFF10B981)),
                        ),
                        child: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? 'التقرير الختامي للبعثة الاستكشافية' : 'MISSION EVA DEBRIEFING',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              isAr ? 'تقييم الأداء العلمي وجمع العينات' : 'PERFORMANCE EVALUATION & SAMPLE MANIFEST',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 9.5,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // X Close Button — dismiss without exiting
                      IconButton(
                        onPressed: () {
                          AudioSynthService.playButtonClick();
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.close_rounded),
                        color: const Color(0xFF64748B),
                        tooltip: isAr ? 'إغلاق والعودة للاستكشاف' : 'Close & Return to Exploration',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF1E293B)),
                  const SizedBox(height: 14),

                  // Mission Stats Table
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF071224),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Column(
                      children: [
                        _buildDebriefRow(
                          isAr ? 'رائد الفضاء:' : 'ASTRONAUT:',
                          '${state.astronaut.name} (${state.astronaut.callSign})',
                          Colors.white,
                        ),
                        const SizedBox(height: 8),
                        _buildDebriefRow(
                          isAr ? 'التخصص والدور:' : 'CREW ROLE:',
                          isAr ? state.astronaut.roleArabic : state.astronaut.role,
                          primaryColor,
                        ),
                        const SizedBox(height: 8),
                        _buildDebriefRow(
                          isAr ? 'الروبوت المرافق:' : 'AI COMPANION:',
                          '${state.astronaut.robotName} // OPERATIONAL',
                          const Color(0xFF38BDF8),
                        ),
                        const SizedBox(height: 8),
                        _buildDebriefRow(
                          isAr ? 'موقع الهبوط:' : 'LANDING SITE:',
                          state.selectedSite.name.toUpperCase(),
                          const Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 8),
                        _buildDebriefRow(
                          isAr ? 'العينات الفضائية المجموعة:' : 'SAMPLES GATHERED:',
                          '${state.samplesCollected} / 3 SAMPLES',
                          const Color(0xFF10B981),
                        ),
                        const SizedBox(height: 8),
                        _buildDebriefRow(
                          isAr ? 'مجموع النقاط المحققة:' : 'TOTAL SCORE EARNED:',
                          '${state.explorationPoints} PTS',
                          const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Return to Landing Sites Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 6,
                    ),
                    onPressed: () {
                      AudioSynthService.playButtonClick();
                      Navigator.pop(ctx);
                      Navigator.pushReplacement(
                        context,
                        NasaFadeRoute(page: const MissionSelectionScreen()),
                      );
                    },
                    icon: const Icon(Icons.public, size: 18),
                    label: Text(
                      isAr ? 'العودة لاختيار مواقع الهبوط' : 'RETURN TO MISSION SELECTION',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showExitConfirmationDialog(BuildContext context, bool isAr, Color primaryColor) {
    AudioSynthService.playButtonClick();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xF2081324),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: primaryColor.withValues(alpha: 0.8), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
              const BoxShadow(color: Colors.black, blurRadius: 16),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.15),
                  border: Border.all(color: primaryColor, width: 1.4),
                ),
                child: Icon(Icons.rocket_rounded, color: primaryColor, size: 26),
              ),
              const SizedBox(height: 14),
              Text(
                isAr ? 'العودة لاختيار المهام' : 'RETURN TO MISSIONS?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAr
                    ? 'هل تود إنهاء الجولة الحالية والعودة لشاشة اختيار المهام؟ سيتم حفظ جميع النقاط والعينات تلقائياً.'
                    : 'End the current surface exploration session and return to Mission Selection? All points and samples are safely saved.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF94A3B8),
                        side: const BorderSide(color: Color(0xFF334155)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        AudioSynthService.playButtonClick();
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        isAr ? 'متابعة المهمة' : 'CONTINUE',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        AudioSynthService.playButtonClick();
                        Navigator.pop(ctx);
                        Navigator.pushReplacement(
                          context,
                          NasaFadeRoute(page: const MissionSelectionScreen()),
                        );
                      },
                      child: Text(
                        isAr ? 'تأكيد العودة' : 'CONFIRM EXIT',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebriefRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontFamily: 'monospace'),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);
    final isMars = state.planet == PlanetType.mars;
    final primaryColor = isMars ? const Color(0xFFF97316) : const Color(0xFF38BDF8);
    final isAr = state.language.isArabic;

    final sceneUrl = _isSurfaceMode
        ? 'game_scene.html?planet=${state.planet.name}&site=${state.selectedSite.id}'
        : 'orbit_scene.html?planet=${state.planet.name}&site=${state.selectedSite.id}';
    final viewId = _isSurfaceMode ? 'cockpit-surface-view' : 'cockpit-orbit-view';

    return Directionality(
      textDirection: state.language.textDirection,
      child: KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.space) {
              _triggerJump(viewId);
            } else if (event.logicalKey == LogicalKeyboardKey.keyW || event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _sendDirection(viewId, 'forward', true);
            } else if (event.logicalKey == LogicalKeyboardKey.keyS || event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _sendDirection(viewId, 'backward', true);
            } else if (event.logicalKey == LogicalKeyboardKey.keyA || event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _sendDirection(viewId, 'left', true);
            } else if (event.logicalKey == LogicalKeyboardKey.keyD || event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _sendDirection(viewId, 'right', true);
            }
          } else if (event is KeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.keyW || event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _sendDirection(viewId, 'forward', false);
            } else if (event.logicalKey == LogicalKeyboardKey.keyS || event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _sendDirection(viewId, 'backward', false);
            } else if (event.logicalKey == LogicalKeyboardKey.keyA || event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _sendDirection(viewId, 'left', false);
            } else if (event.logicalKey == LogicalKeyboardKey.keyD || event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _sendDirection(viewId, 'right', false);
            }
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 1. Background 3D Three.js WebGL External Surface View
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: ThreeJsCanvasWidget(
                    key: ValueKey(sceneUrl),
                    scenePath: sceneUrl,
                    viewId: viewId,
                    ignorePointer: true,
                    onMessage: (msg) {
                      if (msg is Map) {
                        if (msg['type'] == 'ASTRONAUT_TELEMETRY') {
                          final x = double.tryParse(msg['x']?.toString() ?? '0') ?? 0.0;
                          final z = double.tryParse(msg['z']?.toString() ?? '0') ?? 0.0;
                          final dist = double.tryParse(msg['distanceToTarget']?.toString() ?? '32') ?? 32.0;
                          final speed = double.tryParse(msg['speed']?.toString() ?? '0') ?? 0.0;
                          final heading = double.tryParse(msg['heading']?.toString() ?? '84') ?? 84.0;
                          final tX = double.tryParse(msg['targetX']?.toString() ?? '26') ?? 26.0;
                          final tZ = double.tryParse(msg['targetZ']?.toString() ?? '-32') ?? -32.0;

                          if (_targetX != tX || _targetZ != tZ) {
                            setState(() {
                              _targetX = tX;
                              _targetZ = tZ;
                            });
                          }

                          notifier.updateAstronautTelemetry(
                            x: x,
                            z: z,
                            distanceToTarget: dist,
                            speed: speed,
                            heading: heading,
                          );
                        } else if (msg['type'] == 'ROVER_TELEMETRY') {
                          final speed = double.tryParse(msg['speed']?.toString() ?? '0') ?? 0.0;
                          final heading = double.tryParse(msg['heading']?.toString() ?? '84') ?? 84.0;
                          notifier.updateRoverTelemetry(speed, heading);
                        } else if (msg['type'] == 'TARGET_CLICKED') {
                          _collectSampleAction(viewId, isAr);
                        }
                      }
                    },
                  ),
                ),
              ),

              // 2. Cockpit Canopy Decorative Viewport Struts
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CockpitCanopyPainter(primaryColor: primaryColor),
                  ),
                ),
              ),

              // 3. Unified Top Navigation Bar (Zero Overlap): Exit (Left), Total Score (Center), Triggers (Right)
              Positioned(
                top: 12,
                left: 14,
                right: 14,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // FAR LEFT: Back Navigation to Mission Selection & Debriefing
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SciFiBackButton(
                            label: isAr ? 'المهام' : 'MISSIONS',
                            isAr: isAr,
                            color: const Color(0xFF38BDF8),
                            onPressed: () => _showExitConfirmationDialog(context, isAr, primaryColor),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xE00C1628),
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF10B981), width: 1.3),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              shadowColor: const Color(0x6610B981),
                              elevation: 6,
                            ),
                            onPressed: () => _showDebriefingDialog(context, state, isAr, primaryColor),
                            icon: const Icon(Icons.assessment_outlined, size: 15, color: Color(0xFF10B981)),
                            label: Text(
                              isAr ? 'التقرير' : 'DEBRIEF',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // CENTER: Persistent Total Score Counter & Sleek +50 Quick Score-Increment Button
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xEE1E1B4B), Color(0xEE090D1C)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x55F59E0B),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 17),
                                const SizedBox(width: 6),
                                Text(
                                  isAr
                                      ? 'مجموع النقاط: ${state.explorationPoints}'
                                      : 'TOTAL SCORE: ${state.explorationPoints} PTS',
                                  style: const TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Sleek Glowing +50 Quick Score-Increment Button (Glassmorphism & Gold Glow)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                ref.read(gameStateProvider.notifier).addScore(50);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xDD1E1B4B),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x66F59E0B),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(color: Colors.black, blurRadius: 6),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, color: Color(0xFFF59E0B), size: 14),
                                    SizedBox(width: 2),
                                    Text(
                                      '50 XP',
                                      style: TextStyle(
                                        color: Color(0xFFF59E0B),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // RIGHT SIDE: In-Zone Missions, Objectives, System Triggers & 3D Globe Toggle
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSurfaceMode) ...[
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xE0051810),
                                foregroundColor: const Color(0xFF10B981),
                                side: const BorderSide(color: Color(0xFF10B981), width: 1.3),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                shadowColor: const Color(0x6610B981),
                                elevation: 6,
                              ),
                              onPressed: () {
                                AudioSynthService.playButtonClick();
                                _showInZoneMissionDialog(context, state, isAr, primaryColor);
                              },
                              icon: const Icon(Icons.explore_outlined, size: 15, color: Color(0xFF10B981)),
                              label: Text(
                                isAr ? 'مهام المنطقة ▾' : 'MISSIONS ▾',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, fontFamily: 'monospace'),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Objectives Trigger with Cyan Neon Glow
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isObjectivesMenuOpen ? const Color(0xFF0F2646) : const Color(0xE0071426),
                              foregroundColor: const Color(0xFF38BDF8),
                              side: BorderSide(
                                color: _isObjectivesMenuOpen ? const Color(0xFF38BDF8) : const Color(0x8838BDF8),
                                width: 1.3,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              shadowColor: const Color(0x6638BDF8),
                              elevation: 6,
                            ),
                            onPressed: () {
                              AudioSynthService.playButtonClick();
                              setState(() {
                                _isObjectivesMenuOpen = !_isObjectivesMenuOpen;
                                if (_isObjectivesMenuOpen) _isSystemMenuOpen = false;
                              });
                            },
                            icon: const Icon(Icons.task_alt, size: 15),
                            label: Text(
                              isAr ? 'الأهداف ▾' : 'OBJECTIVES ▾',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, fontFamily: 'monospace'),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // System Trigger with Glassmorphism Border
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSystemMenuOpen ? const Color(0xFF0F2646) : const Color(0xE00B172A),
                              foregroundColor: primaryColor,
                              side: BorderSide(
                                color: _isSystemMenuOpen ? primaryColor : primaryColor.withValues(alpha: 0.6),
                                width: 1.3,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              shadowColor: primaryColor.withValues(alpha: 0.4),
                              elevation: 6,
                            ),
                            onPressed: () {
                              AudioSynthService.playButtonClick();
                              setState(() {
                                _isSystemMenuOpen = !_isSystemMenuOpen;
                                if (_isSystemMenuOpen) _isObjectivesMenuOpen = false;
                              });
                            },
                            icon: const Icon(Icons.tune, size: 15),
                            label: Text(
                              isAr ? 'النظام ▾' : 'SYSTEM ▾',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, fontFamily: 'monospace'),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 3D Viewport Mode Toggle (3D Globe <-> Surface Rover)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xE0171228),
                              foregroundColor: const Color(0xFFFBBF24),
                              side: const BorderSide(color: Color(0xFFFBBF24), width: 1.3),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              shadowColor: const Color(0x66FBBF24),
                              elevation: 6,
                            ),
                            onPressed: () {
                              AudioSynthService.playButtonClick();
                              setState(() {
                                _isSurfaceMode = !_isSurfaceMode;
                                if (!_isSurfaceMode) {
                                  ref.read(gameStateProvider.notifier).setMissionPhase(MissionPhase.orbitalRecon);
                                } else {
                                  ref.read(gameStateProvider.notifier).setMissionPhase(MissionPhase.surfaceExploration);
                                }
                              });
                            },
                            icon: Icon(
                              _isSurfaceMode ? Icons.public : Icons.terrain_rounded,
                              size: 15,
                              color: const Color(0xFFFBBF24),
                            ),
                            label: Text(
                              _isSurfaceMode
                                  ? (isAr ? 'المدار 3D' : '3D GLOBE')
                                  : (isAr ? 'سطح الكوكب' : 'SURFACE ROVER'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 4. In-Zone Mini-Map (Radar) displaying active target beacon & hazards (Requirement 3)
              if (_isSurfaceMode)
                Positioned(
                  top: 56,
                  left: 14,
                  child: _MiniMapWidget(
                    astronautX: state.astronautX,
                    astronautZ: state.astronautZ,
                    targetX: _targetX,
                    targetZ: _targetZ,
                    headingDeg: state.roverHeadingDeg,
                    primaryColor: primaryColor,
                    isAr: isAr,
                  ),
                ),

              // 4a. Dynamic Hazard Danger Alert Banner & One-Click System Repair
              if (_isSurfaceMode &&
                  (state.activeHazard != HazardType.none ||
                   state.telemetry.oxygenLevelPercent < 30.0 ||
                   state.telemetry.suitPowerPercent < 30.0))
                Positioned(
                  top: 56,
                  left: 130,
                  right: 14,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _HazardAlertBanner(
                      hazard: state.activeHazard,
                      telemetry: state.telemetry,
                      isAr: isAr,
                      onRepair: () => notifier.repairActiveHazard(),
                    ),
                  ),
                ),

              // 4b. Interactive Target Collection Banner when in range (< 15m) (Requirement 1)
              if (_isSurfaceMode && state.distanceToTarget < 15.0)
                Positioned(
                  bottom: 140,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _collectSampleAction(viewId, isAr),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF10B981)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x8810B981),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.touch_app_rounded, color: Colors.white, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                isAr
                                    ? '🎯 اقتربت من الهدف! انقر هنا لجمع العينة (+50 نقطة)'
                                    : '🎯 TARGET IN RANGE! TAP TO COLLECT (+50 XP)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // 5. Panel 1 (Top-Right): System & Telemetry Menu Dropdown Content
              if (_isSystemMenuOpen)
                Positioned(
                  top: 56,
                  right: 14,
                  child: Directionality(
                    textDirection: state.language.textDirection,
                    child: Container(
                      width: 290,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xF0071224),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.7), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.25),
                            blurRadius: 20,
                          ),
                          const BoxShadow(color: Colors.black, blurRadius: 12),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.satellite_alt, color: primaryColor, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                isAr ? 'بيانات النظام والملاحة' : 'SYSTEM & AVIONICS MENU',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () => setState(() => _isSystemMenuOpen = false),
                                child: const Icon(Icons.close, color: Color(0xFF64748B), size: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: Color(0xFF1E293B), height: 1),
                          const SizedBox(height: 10),
                          _buildMenuRow('AVIONICS BUS:', 'NOMINAL // 400Hz', const Color(0xFF10B981)),
                          _buildMenuRow(
                            'COORDINATES:',
                            'X: ${state.astronautX.toStringAsFixed(1)}m | Z: ${state.astronautZ.toStringAsFixed(1)}m',
                            Colors.white,
                          ),
                          _buildMenuRow(
                            'SPEED & HEADING:',
                            '${state.roverSpeedKmh.toStringAsFixed(1)} km/h | ${state.roverHeadingDeg.toStringAsFixed(0)}°',
                            const Color(0xFF38BDF8),
                          ),
                          _buildMenuRow('SPECTROMETER:', 'Basaltic Andesite', const Color(0xFFFBBF24)),
                          _buildMenuRow('H2O ICE SIGNATURE:', 'POSITIVE // 34.2%', const Color(0xFF06B6D4)),
                          _buildMenuRow(
                            'ATMOSPHERE:',
                            isMars ? '610 Pa (CO2 95.3%)' : '10⁻¹⁰ Pa (Vacuum)',
                            const Color(0xFF94A3B8),
                          ),
                          _buildMenuRow(
                            'SURFACE TEMP:',
                            '${state.telemetry.surfaceTemperatureC.toStringAsFixed(1)}°C',
                            const Color(0xFF38BDF8),
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: Color(0xFF1E293B), height: 1),
                          const SizedBox(height: 8),
                          _buildMenuRow(
                            'SUIT O₂ LEVEL:',
                            '${state.telemetry.oxygenLevelPercent.toStringAsFixed(1)}%',
                            state.telemetry.oxygenLevelPercent < 30 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          ),
                          _buildMenuRow(
                            'SUIT POWER MATRIX:',
                            '${state.telemetry.suitPowerPercent.toStringAsFixed(1)}%',
                            state.telemetry.suitPowerPercent < 30 ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
                          ),
                          _buildMenuRow(
                            'ENVIRONMENT HAZARD:',
                            state.activeHazard != HazardType.none ? state.activeHazard.title(isAr) : 'NOMINAL // SECURE',
                            state.activeHazard != HazardType.none ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          ),
                          const SizedBox(height: 10),
                          // Quick Repair / Replenish Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.activeHazard != HazardType.none ? const Color(0xFFDC2626) : const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              notifier.repairActiveHazard();
                            },
                            icon: const Icon(Icons.build_circle_rounded, size: 15),
                            label: Text(
                              isAr ? 'إصلاح الأنظمة وتزويد الموارد (+50 XP)' : 'REPAIR & REPLENISH (+50 XP)',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10.5, fontFamily: 'monospace'),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Hazard Test Trigger Button
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF59E0B),
                              side: const BorderSide(color: Color(0xFFF59E0B), width: 1.0),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              notifier.triggerHazard(HazardType.oxygenLeak);
                            },
                            icon: const Icon(Icons.warning_amber_rounded, size: 15),
                            label: Text(
                              isAr ? 'محاكاة طوارئ (تسريب أكسجين)' : 'TRIGGER TEST HAZARD',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 6. Panel 2 (Top-Right): Mission Objectives & Distance Tracker Dropdown Content
              if (_isObjectivesMenuOpen)
                Positioned(
                  top: 56,
                  right: 14,
                  child: Directionality(
                    textDirection: state.language.textDirection,
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xF0071224),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.7), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                            blurRadius: 20,
                          ),
                          const BoxShadow(color: Colors.black, blurRadius: 12),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.flag, color: Color(0xFF38BDF8), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                isAr ? 'قائمة المهام والأهداف الميدانية' : 'MISSION TASKS & OBJECTIVES',
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () => setState(() => _isObjectivesMenuOpen = false),
                                child: const Icon(Icons.close, color: Color(0xFF64748B), size: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: Color(0xFF1E293B), height: 1),
                          const SizedBox(height: 10),

                          // Active Task Brief
                          if (state.currentTask != null) ...[
                            Text(
                              isAr ? state.currentTask!.titleAr : state.currentTask!.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAr ? state.currentTask!.descriptionAr : state.currentTask!.description,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],

                          // Distance to Nearest Target Sample Beacon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF030A14),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF1E293B)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isAr ? 'المسافة للهدف العلمي:' : 'TARGET DISTANCE:',
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5, fontFamily: 'monospace'),
                                ),
                                Text(
                                  '${state.distanceToTarget.toStringAsFixed(1)} m',
                                  style: const TextStyle(
                                    color: Color(0xFFFBBF24),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Samples Collected Counter
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF030A14),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF1E293B)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isAr ? 'العينات المجموعة:' : 'SAMPLES COLLECTED:',
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5, fontFamily: 'monospace'),
                                ),
                                Text(
                                  '${state.samplesCollected} / 3',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Interactive "Collect Sample" Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _collectSampleAction(viewId, isAr),
                            icon: const Icon(Icons.science, size: 16),
                            label: Text(
                              isAr ? 'جمع العينة الفضائية (+50 نقطة)' : 'COLLECT SAMPLE (+50 XP)',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 7. Compact Directional Movement Controls - Bottom Center
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildMovementControls(viewId, primaryColor, isAr),
                ),
              ),

              // 8. Bottom-Left: 3D Holographic Smart Watch HUD & Crew Radio Comms
              Positioned(
                left: isAr ? null : 20,
                right: isAr ? 20 : null,
                bottom: 20,
                child: const HolographicWatchHUDWidget(),
              ),

              // 9. Bottom-Right: AI Scientific Companion ("AEGIS-7 AI")
              Positioned(
                right: isAr ? null : 20,
                left: isAr ? 20 : null,
                bottom: 20,
                child: const AiCompanionRobotWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 9, fontFamily: 'monospace')),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementControls(String viewId, Color primaryColor, bool isAr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xDD040E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          const BoxShadow(color: Colors.black, blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Sleek Sci-Fi Virtual Analog Joystick (360° Movement)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onPanStart: (details) => _updateJoystick(details.localPosition, viewId),
                onPanUpdate: (details) => _updateJoystick(details.localPosition, viewId),
                onPanEnd: (_) => _resetJoystick(viewId),
                onPanCancel: () => _resetJoystick(viewId),
                child: Container(
                  width: 94,
                  height: 94,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF071224),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.7), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.25),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Target crosshairs & rings
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor.withValues(alpha: 0.25), width: 1),
                        ),
                      ),
                      Positioned(top: 4, child: Icon(Icons.arrow_drop_up, size: 14, color: primaryColor.withValues(alpha: 0.6))),
                      Positioned(bottom: 4, child: Icon(Icons.arrow_drop_down, size: 14, color: primaryColor.withValues(alpha: 0.6))),
                      Positioned(left: 4, child: Icon(Icons.arrow_left, size: 14, color: primaryColor.withValues(alpha: 0.6))),
                      Positioned(right: 4, child: Icon(Icons.arrow_right, size: 14, color: primaryColor.withValues(alpha: 0.6))),
                      // Draggable Thumb Knob
                      Transform.translate(
                        offset: _joystickDelta,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                primaryColor,
                                const Color(0xFF0F2646),
                              ],
                              stops: const [0.2, 1.0],
                            ),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.6),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAr ? 'توجيه 360°' : '360° JOYSTICK',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(width: 18),

          // 2. Sleek Translucent Neon-Cyan Jump Button
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _triggerJump(viewId),
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0284C7),
                        Color(0xFF0F172A),
                      ],
                    ),
                    border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x6638BDF8),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.keyboard_double_arrow_up_rounded,
                      color: Color(0xFF38BDF8),
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isAr ? 'قفز فضائي' : 'JUMP',
                style: const TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateJoystick(Offset localPos, String viewId) {
    const center = Offset(47, 47);
    final delta = localPos - center;
    final dist = delta.distance;
    final clampedDist = dist.clamp(0.0, _joystickRadius);
    final norm = dist > 0 ? delta / dist : Offset.zero;
    final finalOffset = norm * clampedDist;

    setState(() {
      _joystickDelta = finalOffset;
    });

    final normalizedDx = finalOffset.dx / _joystickRadius;
    final normalizedDy = finalOffset.dy / _joystickRadius;

    _sendJoystick(viewId, normalizedDx, normalizedDy);
  }

  void _resetJoystick(String viewId) {
    setState(() {
      _joystickDelta = Offset.zero;
    });
    _sendJoystick(viewId, 0.0, 0.0);
  }
}

// Mini-Map Widget displaying active target beacon & hazards
class _MiniMapWidget extends StatelessWidget {
  final double astronautX;
  final double astronautZ;
  final double targetX;
  final double targetZ;
  final double headingDeg;
  final Color primaryColor;
  final bool isAr;

  const _MiniMapWidget({
    required this.astronautX,
    required this.astronautZ,
    required this.targetX,
    required this.targetZ,
    required this.headingDeg,
    required this.primaryColor,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final dist = math.sqrt(
      math.pow(targetX - astronautX, 2) + math.pow(targetZ - astronautZ, 2),
    );

    return Container(
      width: 110,
      height: 125,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xDD040E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.25),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          const BoxShadow(color: Colors.black, blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'رادار' : 'RADAR',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                '${dist.toStringAsFixed(0)}m',
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomPaint(
                painter: _MiniMapPainter(
                  astronautX: astronautX,
                  astronautZ: astronautZ,
                  targetX: targetX,
                  targetZ: targetZ,
                  headingDeg: headingDeg,
                  primaryColor: primaryColor,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  final double astronautX;
  final double astronautZ;
  final double targetX;
  final double targetZ;
  final double headingDeg;
  final Color primaryColor;

  // Realistic planetary hazard locations
  static const List<Offset> hazards = [
    Offset(18, 14),
    Offset(-22, 18),
    Offset(12, -26),
    Offset(-15, -16),
    Offset(28, -10),
    Offset(-10, 32),
  ];

  _MiniMapPainter({
    required this.astronautX,
    required this.astronautZ,
    required this.targetX,
    required this.targetZ,
    required this.headingDeg,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 2;

    // Dark radar background
    final bgPaint = Paint()..color = const Color(0xFF030A14);
    canvas.drawCircle(center, radius, bgPaint);

    // Range rings (25m & 50m)
    final ringPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.5, ringPaint);
    canvas.drawCircle(center, radius, ringPaint);

    // Radar crosshairs
    final gridPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), gridPaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), gridPaint);

    // 1. Draw Hazards as very small red dots
    final hazardHaloPaint = Paint()..color = const Color(0x66EF4444);
    final hazardCorePaint = Paint()..color = const Color(0xFFEF4444);

    for (final h in hazards) {
      final hdx = h.dx - astronautX;
      final hdz = h.dy - astronautZ;
      final hDist = math.sqrt(hdx * hdx + hdz * hdz);
      if (hDist <= 50.0) {
        final hRatio = hDist / 50.0;
        final hAngle = math.atan2(hdz, hdx);
        final hx = center.dx + hRatio * radius * math.cos(hAngle);
        final hy = center.dy + hRatio * radius * math.sin(hAngle);
        canvas.drawCircle(Offset(hx, hy), 3.5, hazardHaloPaint);
        canvas.drawCircle(Offset(hx, hy), 1.8, hazardCorePaint);
      }
    }

    // 2. Draw Active Target Beacon as glowing white dot
    final tdx = targetX - astronautX;
    final tdz = targetZ - astronautZ;
    final tDist = math.sqrt(tdx * tdx + tdz * tdz);
    final clampedDist = tDist.clamp(0.0, 50.0);
    final tRatio = clampedDist / 50.0;
    final tAngle = math.atan2(tdz, tdx);
    final tx = center.dx + tRatio * radius * math.cos(tAngle);
    final ty = center.dy + tRatio * radius * math.sin(tAngle);

    final targetGlowPaint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    final targetHaloPaint = Paint()..color = const Color(0xAA38BDF8);
    final targetCorePaint = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(tx, ty), 5.5, targetGlowPaint);
    canvas.drawCircle(Offset(tx, ty), 3.5, targetHaloPaint);
    canvas.drawCircle(Offset(tx, ty), 2.2, targetCorePaint);

    // 3. Draw Player Astronaut at center with heading pointer
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((headingDeg - 90) * math.pi / 180);

    final playerPointer = Path()
      ..moveTo(0, -6)
      ..lineTo(4, 5)
      ..lineTo(0, 3)
      ..lineTo(-4, 5)
      ..close();

    final playerPaint = Paint()..color = primaryColor;
    canvas.drawPath(playerPointer, playerPaint);

    final playerCenterPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset.zero, 1.5, playerCenterPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter oldDelegate) {
    return oldDelegate.astronautX != astronautX ||
        oldDelegate.astronautZ != astronautZ ||
        oldDelegate.targetX != targetX ||
        oldDelegate.targetZ != targetZ ||
        oldDelegate.headingDeg != headingDeg ||
        oldDelegate.primaryColor != primaryColor;
  }
}

// Cockpit Canopy Viewport Strut Lines
class _CockpitCanopyPainter extends CustomPainter {
  final Color primaryColor;
  _CockpitCanopyPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final framePaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.75)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.25)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Angled left strut
    final leftPath = Path()
      ..moveTo(0, size.height * 0.4)
      ..lineTo(size.width * 0.25, 0);

    // Angled right strut
    final rightPath = Path()
      ..moveTo(size.width, size.height * 0.4)
      ..lineTo(size.width * 0.75, 0);

    // Center canopy crossbar
    final centerCross = Path()
      ..moveTo(size.width * 0.25, 0)
      ..lineTo(size.width * 0.75, 0);

    canvas.drawPath(leftPath, framePaint);
    canvas.drawPath(rightPath, framePaint);
    canvas.drawPath(centerCross, framePaint);

    canvas.drawPath(leftPath, glowPaint);
    canvas.drawPath(rightPath, glowPaint);
    canvas.drawPath(centerCross, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _CockpitCanopyPainter oldDelegate) => false;
}

/// Dynamic Sci-Fi Hazard Alert & Emergency Repair Holographic Banner
class _HazardAlertBanner extends StatefulWidget {
  final HazardType hazard;
  final TelemetryData telemetry;
  final bool isAr;
  final VoidCallback onRepair;

  const _HazardAlertBanner({
    required this.hazard,
    required this.telemetry,
    required this.isAr,
    required this.onRepair,
  });

  @override
  State<_HazardAlertBanner> createState() => _HazardAlertBannerState();
}

class _HazardAlertBannerState extends State<_HazardAlertBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasHazard = widget.hazard != HazardType.none;
    final isLowO2 = widget.telemetry.oxygenLevelPercent < 30.0;
    final isLowPower = widget.telemetry.suitPowerPercent < 30.0;

    final title = hasHazard
        ? widget.hazard.title(widget.isAr)
        : (widget.isAr
            ? 'إنذار طوارئ: انخفاض حرج في الموارد الحيوية!'
            : 'CRITICAL LIFE-SUPPORT HAZARD ALERT!');

    final desc = hasHazard
        ? widget.hazard.description(widget.isAr)
        : (widget.isAr
            ? 'مستوى الأكسجين أو طاقة البذلة الفضائية هبط دون 30%! أصلح الأنظمة فوراً.'
            : 'O2 reserves or suit battery has dropped under 30%! Repair systems immediately.');

    final repairLabel = hasHazard
        ? widget.hazard.repairLabel(widget.isAr)
        : (widget.isAr ? 'إصلاح وتزويد الموارد (+50 نقطة)' : 'REPAIR & REPLENISH (+50 XP)');

    final icon = hasHazard ? widget.hazard.icon : Icons.warning_amber_rounded;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowAlpha = 0.35 + 0.45 * _pulseController.value;
        final borderColor = Color.lerp(
          const Color(0xFFEF4444),
          const Color(0xFFF59E0B),
          _pulseController.value,
        )!;

        return Directionality(
          textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xF21C0B0B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: glowAlpha),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
                const BoxShadow(color: Colors.black87, blurRadius: 12),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0x33EF4444),
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'HAZARD // ',
                            style: TextStyle(
                              color: borderColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 9.5,
                              fontFamily: 'monospace',
                              letterSpacing: 1,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 11.5,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        desc,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 10,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'O₂: ${widget.telemetry.oxygenLevelPercent.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: isLowO2 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'POWER: ${widget.telemetry.suitPowerPercent.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: isLowPower ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Interactive Repair Action Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onRepair,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFDC2626), Color(0xFFF97316)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x88DC2626),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.build_circle_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            repairLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
