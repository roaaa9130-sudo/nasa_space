import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planet_mission.dart';
import '../providers/game_state_provider.dart';
import '../services/audio_synth_service.dart';
import '../services/navigation_helper.dart';
import '../widgets/three_js_canvas_widget.dart';
import 'landing_screen.dart';
import 'cockpit_screen.dart';
import 'login_screen.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);
    final strings = ref.watch(stringsProvider);
    final notifier = ref.read(gameStateProvider.notifier);
    final isMars = state.planet == PlanetType.mars;
    final primaryColor = isMars ? const Color(0xFFF97316) : const Color(0xFF38BDF8);

    return Directionality(
      textDirection: state.language.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: Stack(
          children: [
            // Background 3D Three.js WebGL Celestial Sphere (Mars / Moon)
            Positioned.fill(
              child: IgnorePointer(
                child: ThreeJsCanvasWidget(
                  scenePath: 'orbit_scene.html',
                  viewId: 'main-menu-canvas',
                  ignorePointer: true,
                  onMessage: (msg) {
                    if (msg is Map && msg['type'] == 'PLANET_CHANGED') {
                      final nextPlanet = msg['planet'] == 'moon' ? PlanetType.moon : PlanetType.mars;
                      notifier.setPlanet(nextPlanet);
                    }
                  },
                ),
              ),
            ),

            // Top Header: NASA Logo, Mission Badge, Language Switcher
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF020617).withValues(alpha: 0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // NASA Insignia
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.public, color: primaryColor, size: 24),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'NASA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Text(
                                '2026 MISSION',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            strings.appTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            strings.missionProgram,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    // Astronaut Profile Badge & Edit Crew
                    InkWell(
                      onTap: () {
                        AudioSynthService.playButtonClick();
                        Navigator.push(
                          context,
                          NasaFadeRoute(page: const LoginScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.badge, color: primaryColor, size: 16),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.astronaut.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                Text(
                                  'BOT: ${state.astronaut.robotName} // ${state.astronaut.callSign}',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 8,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.edit, color: Color(0xFF94A3B8), size: 12),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Language Switcher Button (EN / AR)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.8),
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: primaryColor.withValues(alpha: 0.4)),
                        ),
                      ),
                      icon: const Icon(Icons.language, size: 16),
                      label: Text(
                        strings.switchLanguage,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      onPressed: () => notifier.toggleLanguage(),
                    ),
                  ],
                ),
              ),
            ),

            // Left Side Panel: Planet Selection and Mission Specs
            Positioned(
              left: state.language.isArabic ? null : 24,
              right: state.language.isArabic ? 24 : null,
              top: 90,
              bottom: 24,
              child: SizedBox(
                width: 360,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Celestial Body Selector Cards
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF080F1E).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.35)),
                        boxShadow: [
                          BoxShadow(color: primaryColor.withValues(alpha: 0.1), blurRadius: 20),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.selectCelestialBody.toUpperCase(),
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPlanetTab(
                                  label: state.language.isArabic ? 'المريخ' : 'Mars',
                                  subtitle: '0.38g | CO2',
                                  icon: Icons.circle,
                                  iconColor: const Color(0xFFF97316),
                                  isActive: isMars,
                                  onTap: () {
                                    AudioSynthService.playButtonClick();
                                    notifier.setPlanet(PlanetType.mars);
                                    ThreeJsCanvasWidget.sendMessage('main-menu-canvas', {
                                      'action': 'SET_PLANET',
                                      'planet': 'mars',
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildPlanetTab(
                                  label: state.language.isArabic ? 'القمر' : 'Moon',
                                  subtitle: '0.16g | Vacuum',
                                  icon: Icons.nightlight_round,
                                  iconColor: const Color(0xFF38BDF8),
                                  isActive: !isMars,
                                  onTap: () {
                                    AudioSynthService.playButtonClick();
                                    notifier.setPlanet(PlanetType.moon);
                                    ThreeJsCanvasWidget.sendMessage('main-menu-canvas', {
                                      'action': 'SET_PLANET',
                                      'planet': 'moon',
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            isMars ? strings.marsDesc : strings.moonDesc,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11.5,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Stats Bar
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF1E293B)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  label: state.language.isArabic ? 'الجاذبية' : 'Gravity',
                                  val: isMars ? '3.72 m/s²' : '1.62 m/s²',
                                  color: primaryColor,
                                ),
                                Container(width: 1, height: 24, color: const Color(0xFF334155)),
                                _buildStatItem(
                                  label: state.language.isArabic ? 'نقاط الاستكشاف' : 'Exp Points',
                                  val: '${state.explorationPoints}',
                                  color: Colors.amber,
                                ),
                                Container(width: 1, height: 24, color: const Color(0xFF334155)),
                                _buildStatItem(
                                  label: state.language.isArabic ? 'الحالة' : 'Status',
                                  val: 'NOMINAL',
                                  color: const Color(0xFF10B981),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Mission Launch Action Buttons
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 10,
                        shadowColor: primaryColor.withValues(alpha: 0.6),
                      ),
                      onPressed: () {
                        AudioSynthService.playButtonClick();
                        Navigator.push(
                          context,
                          NasaFadeRoute(page: const LandingScreen()),
                        );
                      },
                      icon: const Icon(Icons.travel_explore, size: 20),
                      label: Text(
                        strings.orbitalSurvey.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.8),
                        side: BorderSide(color: primaryColor.withValues(alpha: 0.6), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        AudioSynthService.playButtonClick();
                        Navigator.push(
                          context,
                          NasaFadeRoute(page: const CockpitScreen()),
                        );
                      },
                      icon: Icon(Icons.flight_takeoff, color: primaryColor, size: 20),
                      label: Text(
                        strings.cockpitHUD.toUpperCase(),
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetTab({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? iconColor.withValues(alpha: 0.2) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? iconColor : const Color(0xFF334155),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required String label, required String val, required Color color}) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace')),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5)),
      ],
    );
  }
}
