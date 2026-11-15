import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planet_mission.dart';
import '../providers/game_state_provider.dart';
import '../services/audio_synth_service.dart';
import '../services/navigation_helper.dart';
import '../widgets/three_js_canvas_widget.dart';
import 'login_screen.dart';
import 'mission_selection_screen.dart';

class LunabaseWelcomeScreen extends ConsumerStatefulWidget {
  const LunabaseWelcomeScreen({super.key});

  @override
  ConsumerState<LunabaseWelcomeScreen> createState() => _LunabaseWelcomeScreenState();
}

class _LunabaseWelcomeScreenState extends ConsumerState<LunabaseWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showHowToPlayDialog(BuildContext context, bool isAr, Color primaryColor) {
    AudioSynthService.playButtonClick();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 580, maxHeight: 620),
          decoration: BoxDecoration(
            color: const Color(0xF2081120),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withValues(alpha: 0.7), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.35),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              const BoxShadow(color: Colors.black, blurRadius: 18),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1A2E),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  border: Border(bottom: BorderSide(color: primaryColor.withValues(alpha: 0.3))),
                ),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: primaryColor, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isAr ? 'دليل استكشاف الفضاء // ناسا 2026' : 'FLIGHT MANUAL // NASA 2026 EXPEDITION',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1.2,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        AudioSynthService.playButtonClick();
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // Instructions List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildManualStep(
                      step: '01',
                      icon: Icons.gamepad_rounded,
                      title: isAr ? 'التحكم والملاحة الحركية' : 'ASTRONAUT & ROVER CONTROLS',
                      desc: isAr
                          ? 'استخدم عصا التحكم اللمسية (Virtual Joystick) أو مفاتيح WASD/الأسهم للتنقل واستكشاف التضاريس ثلاثية الأبعاد.'
                          : 'Use the on-screen virtual joystick or keyboard arrow/WASD keys to traverse the terrain.',
                      accentColor: const Color(0xFF38BDF8),
                    ),
                    const SizedBox(height: 14),
                    _buildManualStep(
                      step: '02',
                      icon: Icons.radar_rounded,
                      title: isAr ? 'تعقب المنارات وجمع العينات النادرة' : 'BEACON TRACKING & SAMPLE EXTRACTION',
                      desc: isAr
                          ? 'اتبع المنارات المشعة والأهداف على البوصلة. اقترب لمسافة أقل من 15 متراً واضغط "جمع العينة" لكسب 50 نقطة!'
                          : 'Follow radiant beacons and HUD compass markers. Get within 15m to extract scientific samples (+50 XP).',
                      accentColor: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 14),
                    _buildManualStep(
                      step: '03',
                      icon: Icons.shield_rounded,
                      title: isAr ? 'إدارة الموارد وإصلاح المخاطر الطارئة' : 'LIFE SUPPORT & EMERGENCY HAZARD REPAIR',
                      desc: isAr
                          ? 'راقب مستويات الأكسجين وطاقة البذلة. عند صدور إنذار الخطر، اضغط زر الإصلاح فوراً لمعالجة التسريب واستعادة الاستقرار!'
                          : 'Monitor O2 and suit power levels. When hazard sirens trigger, tap the Repair Action button immediately to stabilize vitals.',
                      accentColor: const Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 14),
                    _buildManualStep(
                      step: '04',
                      icon: Icons.smart_toy_rounded,
                      title: isAr ? 'المساعد العلمي الذكي ريجنيكس (AEGIS-7)' : 'REGNIX AI SCIENCE ASSISTANT (AEGIS-7)',
                      desc: isAr
                          ? 'تحدث مع الروبوت العلمي AEGIS-7 في أي وقت للاستفسار عن جيولوجيا الكوكب، المياه الجليدية، أو الحصول على إرشادات فورية.'
                          : 'Communicate with AEGIS-7 anytime for geology analysis, water-ice coordinates, and mission guidance.',
                      accentColor: const Color(0xFF10B981),
                    ),
                  ],
                ),
              ),

              // Bottom Dismiss Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      AudioSynthService.playButtonClick();
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      isAr ? 'فهمت التعليمات، مستعد للمهمة!' : 'UNDERSTOOD, READY FOR MISSION!',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualStep({
    required String step,
    required IconData icon,
    required String title,
    required String desc,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A2E).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor, width: 1.2),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'STEP $step // ',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);
    final isMars = state.planet == PlanetType.mars;
    final primaryColor = isMars ? const Color(0xFFF97316) : const Color(0xFF38BDF8);
    final isAr = state.language.isArabic;

    return Directionality(
      textDirection: state.language.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: Stack(
          children: [
            // 1. Background 3D Three.js WebGL Celestial Sphere (Mars / Moon)
            Positioned.fill(
              child: IgnorePointer(
                child: ThreeJsCanvasWidget(
                  scenePath: 'orbit_scene.html?planet=${state.planet.name}',
                  viewId: 'lunabase-welcome-canvas',
                  ignorePointer: true,
                ),
              ),
            ),

            // Subtle gradient overlay for readability
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF020617).withValues(alpha: 0.65),
                        Colors.transparent,
                        const Color(0xFF020617).withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // 2. Top Header Bar: NASA Insignia, Planet Selector, Language Switcher
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF020617).withValues(alpha: 0.95),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      // NASA Meatball Emblem & Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.public, color: primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'NASA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    letterSpacing: 2,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                Text(
                                  'LUNABASE 2026',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Celestial Body Switcher Tabs (Mars / Moon)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B132B).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPlanetPill(
                              label: isAr ? 'المريخ' : 'MARS',
                              isActive: isMars,
                              color: const Color(0xFFF97316),
                              onTap: () {
                                AudioSynthService.playButtonClick();
                                notifier.setPlanet(PlanetType.mars);
                                ThreeJsCanvasWidget.sendMessage('lunabase-welcome-canvas', {
                                  'action': 'SET_PLANET',
                                  'planet': 'mars',
                                });
                              },
                            ),
                            const SizedBox(width: 4),
                            _buildPlanetPill(
                              label: isAr ? 'القمر' : 'MOON',
                              isActive: !isMars,
                              color: const Color(0xFF38BDF8),
                              onTap: () {
                                AudioSynthService.playButtonClick();
                                notifier.setPlanet(PlanetType.moon);
                                ThreeJsCanvasWidget.sendMessage('lunabase-welcome-canvas', {
                                  'action': 'SET_PLANET',
                                  'planet': 'moon',
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Language Switcher Button (EN / العربية)
                      InkWell(
                        onTap: () {
                          AudioSynthService.playButtonClick();
                          notifier.toggleLanguage();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.language, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                isAr ? 'English' : 'العربية',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
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

            // 3. Central Mission Briefing & Action Hub
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final glowAlpha = 0.2 + 0.15 * _pulseController.value;
                      return Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: const Color(0xF207101E),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.6 + 0.2 * _pulseController.value),
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: glowAlpha),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                            const BoxShadow(
                              color: Colors.black87,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Mission Program Badge
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: primaryColor, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.military_tech_rounded, color: primaryColor, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      isAr
                                          ? 'محطة استكشاف المريخ والقمر 2026'
                                          : 'LUNABASE & MARS ARTEMIS INITIATIVE',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 9.5,
                                        letterSpacing: 1.2,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Main Title
                            Text(
                              isAr
                                  ? 'رحلة استكشاف الفضاء الواقعية'
                                  : 'NASA DEEP SPACE EXPEDITION',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: 0.5,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Subtitle
                            Text(
                              isAr
                                  ? 'محاكاة علمية تفاعلية ثلاثية الأبعاد لاستكشاف سطح الكواكب، جمع العينات، والتعاون مع الذكاء الاصطناعي ريجنيكس'
                                  : 'Realistic 3D surface simulation, robotic beacon sampling, life support systems, and Regnix AI companion.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12.5,
                                height: 1.45,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Quick Planet Telemetry Snapshot
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D1728),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF1E293B)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildQuickStat(
                                    label: isAr ? 'الوجهة' : 'TARGET',
                                    val: state.planet.displayName.toUpperCase(),
                                    color: primaryColor,
                                  ),
                                  Container(width: 1, height: 26, color: const Color(0xFF334155)),
                                  _buildQuickStat(
                                    label: isAr ? 'الجاذبية' : 'GRAVITY',
                                    val: isMars ? '3.72 m/s²' : '1.62 m/s²',
                                    color: Colors.white,
                                  ),
                                  Container(width: 1, height: 26, color: const Color(0xFF334155)),
                                  _buildQuickStat(
                                    label: isAr ? 'المساعد' : 'AI BOT',
                                    val: 'AEGIS-7',
                                    color: const Color(0xFF10B981),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // PRIMARY ACTION BUTTON 1: "START MISSION" (Navigates to LoginScreen)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 12,
                                shadowColor: primaryColor.withValues(alpha: 0.8),
                              ),
                              onPressed: () {
                                AudioSynthService.playButtonClick();
                                Navigator.push(
                                  context,
                                  NasaFadeRoute(page: const LoginScreen()),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.rocket_launch_rounded, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    isAr ? 'بدء المهمة الفضائية' : 'START MISSION',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 1.2,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // SECONDARY ACTION BUTTON 2: "MISSION SELECTION"
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF0F1A2E).withValues(alpha: 0.85),
                                side: BorderSide(color: primaryColor.withValues(alpha: 0.6), width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {
                                AudioSynthService.playButtonClick();
                                Navigator.push(
                                  context,
                                  NasaFadeRoute(page: const MissionSelectionScreen()),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.travel_explore_rounded, color: primaryColor, size: 19),
                                  const SizedBox(width: 10),
                                  Text(
                                    isAr ? 'اختيار المهمة والسطح' : 'MISSION SELECTION',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 1.0,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // TERTIARY ACTION BUTTON 3: "HOW TO PLAY"
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF94A3B8),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Color(0xFF1E293B)),
                                ),
                              ),
                              onPressed: () => _showHowToPlayDialog(context, isAr, primaryColor),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.help_outline_rounded, size: 17),
                                  const SizedBox(width: 8),
                                  Text(
                                    isAr ? 'دليل اللعب والتحكم' : 'HOW TO PLAY & MANUAL',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetPill({
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF94A3B8),
            fontWeight: FontWeight.w900,
            fontSize: 11,
            fontFamily: 'monospace',
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat({required String label, required String val, required Color color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          val,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11.5,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5),
        ),
      ],
    );
  }
}
