import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planet_mission.dart';
import '../providers/game_state_provider.dart';
import '../services/audio_synth_service.dart';
import '../services/navigation_helper.dart';
import '../widgets/sci_fi_back_button.dart';
import '../widgets/three_js_canvas_widget.dart';
import 'cockpit_screen.dart';
import 'landing_screen.dart';
import 'login_screen.dart';

class MissionSelectionScreen extends ConsumerStatefulWidget {
  const MissionSelectionScreen({super.key});

  @override
  ConsumerState<MissionSelectionScreen> createState() => _MissionSelectionScreenState();
}

class _MissionSelectionScreenState extends ConsumerState<MissionSelectionScreen> {
  LandingSite? _selectedSite;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(gameStateProvider);
      setState(() {
        _selectedSite = state.selectedSite;
      });
    });
  }

  void _onPlanetChanged(PlanetType planet) {
    AudioSynthService.playButtonClick();
    final notifier = ref.read(gameStateProvider.notifier);
    notifier.setPlanet(planet);

    final sites = PlanetaryCatalog.getSitesFor(planet);
    setState(() {
      _selectedSite = sites.first;
    });

    ThreeJsCanvasWidget.sendMessage('mission-select-canvas', {
      'action': 'SET_PLANET',
      'planet': planet.name,
    });
  }

  void _onSiteSelected(LandingSite site) {
    AudioSynthService.playButtonClick();
    ref.read(gameStateProvider.notifier).selectSite(site);
    setState(() {
      _selectedSite = site;
    });
  }

  void _launchSurfaceMission(LandingSite site) {
    AudioSynthService.playThrusterRumble();
    ref.read(gameStateProvider.notifier).selectSite(site);
    ref.read(gameStateProvider.notifier).setMissionPhase(MissionPhase.surfaceExploration);

    Navigator.push(
      context,
      NasaFadeRoute(
        page: const CockpitScreen(initialSurfaceMode: true),
      ),
    );
  }

  void _launchOrbitalSurvey(LandingSite site) {
    AudioSynthService.playButtonClick();
    ref.read(gameStateProvider.notifier).selectSite(site);
    ref.read(gameStateProvider.notifier).setMissionPhase(MissionPhase.orbitalRecon);

    Navigator.push(
      context,
      NasaFadeRoute(
        page: const LandingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);
    ref.watch(stringsProvider);
    final isMars = state.planet == PlanetType.mars;
    final primaryColor = isMars ? const Color(0xFFF97316) : const Color(0xFF38BDF8);
    final isAr = state.language.isArabic;
    final sites = PlanetaryCatalog.getSitesFor(state.planet);
    final activeSite = _selectedSite ?? sites.first;

    return Directionality(
      textDirection: state.language.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: Stack(
          children: [
            // 1. Background 3D Celestial WebGL Canvas
            Positioned.fill(
              child: IgnorePointer(
                child: ThreeJsCanvasWidget(
                  scenePath: 'orbit_scene.html?planet=${state.planet.name}',
                  viewId: 'mission-select-canvas',
                  ignorePointer: true,
                ),
              ),
            ),

            // Semi-transparent dark overlay for text readability
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF020617).withValues(alpha: 0.88),
                        const Color(0xFF020617).withValues(alpha: 0.65),
                        const Color(0xFF020617).withValues(alpha: 0.94),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. Responsive Top Navigation Header
            Positioned(
              top: 12,
              left: 14,
              right: 14,
              child: Row(
                children: [
                  // Glowing Sci-Fi Back Button to Login Screen
                  SciFiBackButton(
                    label: isAr ? 'تسجيل الطاقم' : 'LOGIN',
                    isAr: isAr,
                    color: primaryColor,
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          NasaFadeRoute(page: const LoginScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),

                  // NASA Mission Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF080F1E).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.public, color: primaryColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'NASA 2026',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            fontFamily: 'monospace',
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Active Astronaut Credentials Badge (Flexible to prevent right overflow)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF080F1E).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.badge, color: Color(0xFF10B981), size: 14),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${state.astronaut.name} • ${state.astronaut.callSign}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Language Switcher
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF080F1E).withValues(alpha: 0.9),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFF334155)),
                      ),
                    ),
                    onPressed: () {
                      AudioSynthService.playButtonClick();
                      ref.read(gameStateProvider.notifier).toggleLanguage();
                    },
                    icon: const Icon(Icons.language, size: 14, color: Color(0xFF38BDF8)),
                    label: Text(
                      isAr ? 'EN' : 'عربي',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Fully Responsive Main Content Area (LayoutBuilder prevents all overflows)
            Positioned.fill(
              top: 60,
              left: 14,
              right: 14,
              bottom: 12,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 940;

                  if (isWide) {
                    return _buildWideLayout(
                      state: state,
                      activeSite: activeSite,
                      sites: sites,
                      primaryColor: primaryColor,
                      isMars: isMars,
                      isAr: isAr,
                      constraints: constraints,
                    );
                  } else {
                    return _buildNarrowScrollableLayout(
                      state: state,
                      activeSite: activeSite,
                      sites: sites,
                      primaryColor: primaryColor,
                      isMars: isMars,
                      isAr: isAr,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDE SCREEN LAYOUT: Side-by-side with scrollable right mission grid
  Widget _buildWideLayout({
    required GameState state,
    required LandingSite activeSite,
    required List<LandingSite> sites,
    required Color primaryColor,
    required bool isMars,
    required bool isAr,
    required BoxConstraints constraints,
  }) {
    final leftWidth = (constraints.maxWidth * 0.38).clamp(320.0, 420.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Planet tabs & Selected Mission Details
        SizedBox(
          width: leftWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPlanetTabs(primaryColor, isMars, isAr),
              const SizedBox(height: 10),
              Expanded(
                child: _buildMissionDetailCard(activeSite, primaryColor, isAr),
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // Right Column: 4 Distinct Planetary Missions in scrollable grid
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(state, primaryColor, isAr),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: (constraints.maxWidth > 1200) ? 1.45 : 1.30,
                  ),
                  itemCount: sites.length,
                  itemBuilder: (context, index) {
                    final site = sites[index];
                    return _buildMissionCard(site, index, activeSite.id == site.id, primaryColor, isAr);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // NARROW SCREEN LAYOUT: Single scrollable vertical stream (no overflows)
  Widget _buildNarrowScrollableLayout({
    required GameState state,
    required LandingSite activeSite,
    required List<LandingSite> sites,
    required Color primaryColor,
    required bool isMars,
    required bool isAr,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPlanetTabs(primaryColor, isMars, isAr),
          const SizedBox(height: 14),
          _buildSectionHeader(state, primaryColor, isAr),
          const SizedBox(height: 10),
          // 4 Missions List / Compact Grid
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sites.length,
            itemBuilder: (context, index) {
              final site = sites[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildMissionCard(site, index, activeSite.id == site.id, primaryColor, isAr),
              );
            },
          ),
          const SizedBox(height: 14),
          _buildMissionDetailCard(activeSite, primaryColor, isAr),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(GameState state, Color primaryColor, bool isAr) {
    return Row(
      children: [
        Icon(Icons.radar, color: primaryColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            isAr
                ? 'اختر إحدى المهام الكوكبية الأربع (${state.planet.displayArabic}):'
                : 'SELECT ONE OF 4 MISSIONS (${state.planet.displayName.toUpperCase()}):',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: 'monospace',
              letterSpacing: 0.8,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanetTabs(Color primaryColor, bool isMars, bool isAr) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xEE060D1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPlanetTab(
              label: isAr ? 'المريخ (الكوكب الأحمر)' : 'MARS (RED PLANET)',
              subtitle: '0.38g • 610 Pa',
              icon: Icons.public,
              color: const Color(0xFFF97316),
              isSelected: isMars,
              onTap: () => _onPlanetChanged(PlanetType.mars),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildPlanetTab(
              label: isAr ? 'القمر (لونا)' : 'MOON (LUNA)',
              subtitle: '0.16g • Vacuum',
              icon: Icons.nightlight_round,
              color: const Color(0xFF38BDF8),
              isSelected: !isMars,
              onTap: () => _onPlanetChanged(PlanetType.moon),
            ),
          ),
        ],
      ),
    );
  }

  // Selected Mission Details & Launch Panel
  Widget _buildMissionDetailCard(LandingSite activeSite, Color primaryColor, bool isAr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xEE060D1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.2),
            blurRadius: 18,
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mission Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withValues(alpha: 0.15),
                    border: Border.all(color: primaryColor),
                  ),
                  child: Icon(Icons.explore, color: primaryColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? activeSite.nameArabic : activeSite.name,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        activeSite.coordinateString,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(color: Color(0xFF1E293B)),
            const SizedBox(height: 8),

            // Mission Description
            Text(
              isAr ? 'وصف الموقع والبيئة:' : 'MISSION PROFILE & TERRAIN:',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isAr ? activeSite.descriptionArabic : activeSite.description,
              style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.35),
            ),

            const SizedBox(height: 10),

            // Elevation & Hazard Rating Grid
            Row(
              children: [
                Expanded(
                  child: _buildParamBox(
                    isAr ? 'الارتفاع الطبوغرافي' : 'ELEVATION',
                    '${activeSite.elevationKm >= 0 ? '+' : ''}${activeSite.elevationKm} km',
                    const Color(0xFF38BDF8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildParamBox(
                    isAr ? 'مؤشر الخطورة' : 'HAZARD RATING',
                    '${(activeSite.hazardRating * 100).toInt()}% ${activeSite.hazardRating < 0.4 ? 'LOW' : 'HIGH'}',
                    activeSite.hazardRating < 0.4 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Scientific Goals
            Text(
              isAr ? 'الأهداف العلمية للبعثة:' : 'SCIENTIFIC OBJECTIVES:',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            ...((isAr ? activeSite.scientificGoalsArabic : activeSite.scientificGoals).map((goal) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: primaryColor, size: 12),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        goal,
                        style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 10.5),
                      ),
                    ),
                  ],
                ),
              );
            })),

            const SizedBox(height: 16),

            // Action Buttons
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 6,
              ),
              onPressed: () => _launchSurfaceMission(activeSite),
              icon: const Icon(Icons.terrain, size: 16),
              label: Text(
                isAr ? 'بدء الهبوط والاستكشاف السطحي' : 'INITIATE SURFACE DESCENT',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.6),
              ),
            ),
            const SizedBox(height: 6),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF0F1E36).withValues(alpha: 0.7),
                side: BorderSide(color: primaryColor.withValues(alpha: 0.6)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _launchOrbitalSurvey(activeSite),
              icon: const Icon(Icons.public, size: 15),
              label: Text(
                isAr ? 'المسح المداري ثلاثي الأبعاد (3D)' : 'ORBITAL 3D RECONNAISSANCE',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Single Mission Card (Robust against all text/aspect ratio overflows)
  Widget _buildMissionCard(LandingSite site, int index, bool isSelected, Color primaryColor, bool isAr) {
    return InkWell(
      onTap: () => _onSiteSelected(site),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0F2646).withValues(alpha: 0.95)
              : const Color(0xDD060D1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFF1E293B),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 14,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Badges
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    'MISSION 0${index + 1}',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: site.hazardRating < 0.4
                        ? const Color(0xFF10B981).withValues(alpha: 0.2)
                        : const Color(0xFFEF4444).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    site.hazardRating < 0.4 ? 'OPTIMAL' : 'HAZARDOUS',
                    style: TextStyle(
                      color: site.hazardRating < 0.4
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Site Name
            Text(
              isAr ? site.nameArabic : site.name,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Site Description (maxLines: 2 with ellipsis ensures NO vertical overflow)
            Text(
              isAr ? site.descriptionArabic : site.description,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Bottom coordinates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  site.coordinateString,
                  style: TextStyle(
                    color: primaryColor.withValues(alpha: 0.8),
                    fontSize: 9,
                    fontFamily: 'monospace',
                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? primaryColor : const Color(0xFF475569),
                  size: 15,
                ),
              ],
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
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF1E293B),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? color : const Color(0xFF64748B),
                fontSize: 8,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParamBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF030712),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 8, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
