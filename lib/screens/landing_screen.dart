import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planet_mission.dart';
import '../providers/game_state_provider.dart';
import '../services/audio_synth_service.dart';
import '../services/navigation_helper.dart';
import '../widgets/ai_companion_widget.dart';
import '../widgets/cinematic_descent_widget.dart';
import '../widgets/holographic_hud_widget.dart';
import '../widgets/sci_fi_back_button.dart';
import '../widgets/three_js_canvas_widget.dart';
import 'cockpit_screen.dart';
import 'mission_selection_screen.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final String _viewId = 'landing-orbit-canvas';
  LandingSite? _activePinSite;
  bool _isWatchHudOpen = false;
  bool _isDescentInProgress = false;
  bool _globeTouchMode = true; // User can freely drag/rotate/zoom or toggle UI focus

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(gameStateProvider);
      setState(() {
        _activePinSite = state.selectedSite;
      });
    });
  }

  void _onSitePicked(LandingSite site) {
    AudioSynthService.playButtonClick();
    setState(() {
      _activePinSite = site;
      _isWatchHudOpen = false;
    });
    ref.read(gameStateProvider.notifier).selectSite(site);
    ThreeJsCanvasWidget.sendMessage(_viewId, {
      'action': 'SET_TARGET_COORDINATES',
      'lat': site.latitude,
      'lng': site.longitude,
      'name': site.name,
    });
  }

  void _travelToSite(LandingSite site) {
    AudioSynthService.playThrusterRumble();
    ref.read(gameStateProvider.notifier).selectSite(site);
    ref.read(gameStateProvider.notifier).setMissionPhase(MissionPhase.descentTrajectory);
    setState(() {
      _isDescentInProgress = true;
    });
  }

  void _onDescentFinished() {
    ref.read(gameStateProvider.notifier).setMissionPhase(MissionPhase.surfaceExploration);
    setState(() {
      _isDescentInProgress = false;
    });
    Navigator.pushReplacement(
      context,
      NasaFadeRoute(
        page: const CockpitScreen(initialSurfaceMode: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);
    final strings = ref.watch(stringsProvider);
    final notifier = ref.read(gameStateProvider.notifier);
    final isMars = state.planet == PlanetType.mars;
    final primaryColor = isMars ? const Color(0xFFF97316) : const Color(0xFF38BDF8);
    final sites = PlanetaryCatalog.getSitesFor(state.planet);

    // If a site card or watch HUD is open, or if globe touch is off,
    // canvas ignores pointer so that all Flutter UI buttons, chips, and cards
    // are 100% interactive with zero pointer event absorption!
    final bool canvasIgnorePointer = !_globeTouchMode || _activePinSite != null || _isWatchHudOpen;

    return Directionality(
      textDirection: state.language.textDirection,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 1. Fully Interactive 3D Orbit Globe with Clickable 3D Map Pins
            Positioned.fill(
              child: IgnorePointer(
                ignoring: canvasIgnorePointer,
                child: ThreeJsCanvasWidget(
                  scenePath: 'orbit_scene.html?planet=${state.planet.name}',
                  viewId: _viewId,
                  ignorePointer: canvasIgnorePointer,
                onMessage: (msg) {
                  if (msg is Map) {
                    if (msg['type'] == 'PIN_CLICKED') {
                      AudioSynthService.playButtonClick();
                      final siteId = msg['siteId']?.toString();
                      final match = sites.firstWhere(
                        (s) => s.id == siteId,
                        orElse: () => sites.first,
                      );
                      setState(() {
                        _activePinSite = match;
                        _isWatchHudOpen = false;
                      });
                      notifier.selectSite(match);
                    } else if (msg['type'] == 'TRAVEL_TO_SITE') {
                      final siteId = msg['siteId']?.toString();
                      final match = sites.firstWhere(
                        (s) => s.id == siteId,
                        orElse: () => sites.first,
                      );
                      _travelToSite(match);
                    }
                  }
                },
              ),
            ),
          ),

            // 2. Top Sleek Status Bar & Navigation
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        SciFiBackButton(
                          label: state.language.isArabic ? 'المهام' : 'MISSIONS',
                          isAr: state.language.isArabic,
                          color: primaryColor,
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacement(
                                context,
                                NasaFadeRoute(page: const MissionSelectionScreen()),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                strings.landingSiteSelection.toUpperCase(),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: primaryColor, width: 0.8),
                                ),
                                child: Text(
                                  state.planet.displayName.toUpperCase(),
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Touch mode toggle (3D Globe vs UI)
                        _buildHeaderBtn(
                          icon: _globeTouchMode ? Icons.public : Icons.touch_app,
                          label: _globeTouchMode ? '3D GLOBE' : 'UI LOCK',
                          color: _globeTouchMode ? const Color(0xFF10B981) : primaryColor,
                          isActive: _globeTouchMode,
                          onTap: () {
                            AudioSynthService.playButtonClick();
                            setState(() => _globeTouchMode = !_globeTouchMode);
                          },
                        ),
                        const SizedBox(width: 6),

                        // Controls: Grid Toggle, Rotate Toggle
                        _buildHeaderBtn(
                          icon: Icons.grid_4x4,
                          label: 'GRID',
                          color: primaryColor,
                          isActive: state.isGridActive,
                          onTap: () {
                            AudioSynthService.playButtonClick();
                            notifier.toggleGrid();
                            ThreeJsCanvasWidget.sendMessage(_viewId, {'action': 'TOGGLE_GRID'});
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildHeaderBtn(
                          icon: Icons.sync,
                          label: 'ROTATE',
                          color: primaryColor,
                          isActive: state.isAutoRotateActive,
                          onTap: () {
                            AudioSynthService.playButtonClick();
                            notifier.toggleAutoRotate();
                            ThreeJsCanvasWidget.sendMessage(_viewId, {'action': 'TOGGLE_AUTO_ROTATE'});
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Sleek Minimal Horizontal Pin Quick-Select Chips (Always 100% interactive)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: sites.map((site) {
                          final isSelected = _activePinSite?.id == site.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(
                                state.language.isArabic ? site.nameArabic : site.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: primaryColor,
                              backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.9),
                              side: BorderSide(
                                color: isSelected ? primaryColor : const Color(0xFF334155),
                                width: 1,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              onSelected: (_) => _onSitePicked(site),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Sleek, Compact Floating Info Card when Pin is Selected
            if (_activePinSite != null)
              Positioned(
                left: state.language.isArabic ? null : 20,
                right: state.language.isArabic ? 20 : null,
                bottom: 24,
                child: _buildCompactFloatingSiteCard(
                  site: _activePinSite!,
                  primaryColor: primaryColor,
                  strings: strings,
                  isArabic: state.language.isArabic,
                ),
              ),

            // 4. AI Companion Robot (AEGIS-7) on Orbit/Landing Survey
            Positioned(
              left: state.language.isArabic ? null : 20,
              right: state.language.isArabic ? 20 : null,
              bottom: _activePinSite != null ? 220 : 24,
              child: const AiCompanionRobotWidget(),
            ),

            // 5. Small, Sleek Circular Hardware Smartwatch HUD with Alarms
            Positioned(
              right: state.language.isArabic ? null : 20,
              left: state.language.isArabic ? 20 : null,
              bottom: 24,
              child: HolographicWatchHUDWidget(
                initialOpen: _isWatchHudOpen,
                onToggle: (isOpen) {
                  setState(() => _isWatchHudOpen = isOpen);
                },
              ),
            ),

            // 6. Full-Screen Spacecraft Boarding & Surface Descent Transition Sequence
            if (_isDescentInProgress && _activePinSite != null)
              Positioned.fill(
                child: CinematicDescentWidget(
                  site: _activePinSite!,
                  planet: state.planet,
                  isArabic: state.language.isArabic,
                  onDescentComplete: _onDescentFinished,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactFloatingSiteCard({
    required LandingSite site,
    required Color primaryColor,
    required dynamic strings,
    required bool isArabic,
  }) {
    Color hazardColor = const Color(0xFF10B981);
    String hazardLabel = 'LOW';
    if (site.hazardRating > 0.6) {
      hazardColor = const Color(0xFFEF4444);
      hazardLabel = 'HIGH';
    } else if (site.hazardRating > 0.35) {
      hazardColor = const Color(0xFFF59E0B);
      hazardLabel = 'MODERATE';
    }

    return Container(
      width: 320,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF080F1E).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Site Name & Dismiss 'X'
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                  boxShadow: [BoxShadow(color: primaryColor, blurRadius: 6)],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic ? site.nameArabic : site.name,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () {
                  AudioSynthService.playButtonClick();
                  setState(() => _activePinSite = null);
                },
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.close, color: Color(0xFF94A3B8), size: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Coordinates & Elevation Pills
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 11, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(
                      site.coordinateString,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Text(
                  '${site.elevationKm > 0 ? '+' : ''}${site.elevationKm.toStringAsFixed(1)} km',
                  style: TextStyle(color: primaryColor, fontSize: 10, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Hazard Level Indicator
          Row(
            children: [
              Text(
                strings.hazardRating,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
              const Spacer(),
              Text(
                '${(site.hazardRating * 100).toInt()}% ($hazardLabel)',
                style: TextStyle(color: hazardColor, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: site.hazardRating,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(hazardColor),
              minHeight: 3,
            ),
          ),

          const SizedBox(height: 12),

          // "Travel / Land Here" Prominent Action Button -> Triggers Boarding & Descent!
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 8,
              shadowColor: primaryColor.withValues(alpha: 0.5),
            ),
            onPressed: () => _travelToSite(site),
            icon: const Icon(Icons.rocket_launch, size: 16),
            label: Text(
              strings.travelOrLandHere.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBtn({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.25) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isActive ? color : const Color(0xFF334155)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? color : const Color(0xFF94A3B8), size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? color : const Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
                fontSize: 9.5,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
