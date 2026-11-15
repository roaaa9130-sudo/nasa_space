import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/crew_model.dart';
import '../models/planet_mission.dart';
import '../providers/game_state_provider.dart';
import '../services/audio_synth_service.dart';
import '../services/navigation_helper.dart';
import '../services/web_platform_service.dart';
import '../widgets/sci_fi_back_button.dart';
import 'lunabase_welcome_screen.dart';
import 'mission_selection_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(text: 'Commander Alex Mercer');
  late final TextEditingController _callSignController = TextEditingController(text: 'ARES-1');
  late final TextEditingController _robotController = TextEditingController(text: 'AEGIS-7');
  String _selectedRole = 'Mission Commander';
  PlanetType _selectedPlanet = PlanetType.mars;

  final List<Map<String, String>> _roles = [
    {'en': 'Mission Commander', 'ar': 'قائد البعثة الفضائية'},
    {'en': 'Planetary Geologist', 'ar': 'كبير الجيولوجيين الكوكبيين'},
    {'en': 'Astrobiologist', 'ar': 'أخصائي علم الأحياء الفلكية'},
    {'en': 'Avionics Systems Engineer', 'ar': 'مهندس أنظمة الملاحة والطيران'},
  ];

  // Dynamic 4 Independent Crew Member Profiles (Requirement 2)
  final Map<String, AstronautProfile> _roleProfiles = {
    'Mission Commander': const AstronautProfile(
      name: 'Commander Alex Mercer',
      callSign: 'ARES-1',
      role: 'Mission Commander',
      roleArabic: 'قائد البعثة الفضائية',
      robotName: 'AEGIS-7',
      clearanceLevel: 'NASA LEVEL-5 TOP SECRET',
    ),
    'Planetary Geologist': const AstronautProfile(
      name: 'Dr. Marcus Vance',
      callSign: 'GEO-2',
      role: 'Planetary Geologist',
      roleArabic: 'كبير الجيولوجيين الكوكبيين',
      robotName: 'AEGIS-7',
      clearanceLevel: 'USGS / NASA FIELD SCIENCE',
    ),
    'Astrobiologist': const AstronautProfile(
      name: 'Dr. Tariq Al-Hashimi',
      callSign: 'BIO-3',
      role: 'Astrobiologist',
      roleArabic: 'أخصائي علم الأحياء الفلكية',
      robotName: 'AEGIS-7',
      clearanceLevel: 'GATEWAY BIO-CONTAINMENT',
    ),
    'Avionics Systems Engineer': const AstronautProfile(
      name: 'Lt. Elena Rostova',
      callSign: 'NAV-4',
      role: 'Avionics Systems Engineer',
      roleArabic: 'مهندس أنظمة الملاحة والطيران',
      robotName: 'AEGIS-7',
      clearanceLevel: 'ORBITAL DYNAMICS SPECIALIST',
    ),
  };

  @override
  void initState() {
    super.initState();
    debugPrint('🪐 [NASA UI] LoginScreen initState() starting...');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🎉 [NASA UI] LoginScreen first frame rendered! Ensuring web splash is dismissed.');
      WebPlatformService.dismissSplashScreen('LoginScreen first frame rendered');
    });

    try {
      final profile = ref.read(gameStateProvider).astronaut;
      _selectedRole = profile.role.isNotEmpty ? profile.role : 'Mission Commander';
      if (!_roleProfiles.containsKey(_selectedRole)) {
        _selectedRole = 'Mission Commander';
      }

      final activeProfile = _roleProfiles[_selectedRole]!;
      _nameController.text = profile.name.isNotEmpty ? profile.name : activeProfile.name;
      _callSignController.text = profile.callSign.isNotEmpty ? profile.callSign : activeProfile.callSign;
      _robotController.text = profile.robotName.isNotEmpty ? profile.robotName : 'AEGIS-7';
      _selectedPlanet = ref.read(gameStateProvider).planet;
      debugPrint('✅ [NASA UI] LoginScreen initialized. Role: $_selectedRole, Planet: ${_selectedPlanet.name}');
    } catch (e, stack) {
      debugPrint('⚠️ [NASA UI] LoginScreen initState fallback used: $e\n$stack');
    }
  }

  void _selectRole(String roleEn) {
    if (_selectedRole == roleEn) return;
    AudioSynthService.playButtonClick();

    // Preserve user edits for the previous role
    final prev = _roleProfiles[_selectedRole] ?? const AstronautProfile();
    _roleProfiles[_selectedRole] = prev.copyWith(
      name: _nameController.text.trim(),
      callSign: _callSignController.text.trim(),
    );

    // Switch to target role profile
    final target = _roleProfiles[roleEn]!;
    setState(() {
      _selectedRole = roleEn;
      _nameController.text = target.name;
      _callSignController.text = target.callSign;
      if (_robotController.text.trim().isEmpty) {
        _robotController.text = 'AEGIS-7';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _callSignController.dispose();
    _robotController.dispose();
    super.dispose();
  }

  void _submitAndLaunch() {
    if (!_formKey.currentState!.validate()) return;
    AudioSynthService.playButtonClick();

    final roleMap = _roles.firstWhere(
      (r) => r['en'] == _selectedRole,
      orElse: () => _roles.first,
    );

    final profile = AstronautProfile(
      name: _nameController.text.trim(),
      callSign: _callSignController.text.trim(),
      role: roleMap['en']!,
      roleArabic: roleMap['ar']!,
      robotName: _robotController.text.trim().isEmpty ? 'AEGIS-7' : _robotController.text.trim(),
      clearanceLevel: _roleProfiles[_selectedRole]?.clearanceLevel ?? 'NASA LEVEL-5 TOP SECRET',
    );

    ref.read(gameStateProvider.notifier).setAstronautProfile(profile);
    ref.read(gameStateProvider.notifier).setPlanet(_selectedPlanet);

    Navigator.pushReplacement(
      context,
      NasaFadeRoute(page: const MissionSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🪐 [NASA UI] Building LoginScreen layout...');
    GameState? state;
    try {
      state = ref.watch(gameStateProvider);
    } catch (e, stack) {
      debugPrint('⚠️ [NASA UI] Error watching gameStateProvider in LoginScreen: $e\n$stack');
    }

    final isAr = state?.language.isArabic ?? false;
    final textDirection = state?.language.textDirection ?? TextDirection.ltr;
    final primaryColor = _selectedPlanet == PlanetType.mars
        ? const Color(0xFFF97316)
        : const Color(0xFF38BDF8);

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: Stack(
          children: [
            // Sci-Fi Deep Space Ambient Backdrop
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.2),
                      radius: 1.2,
                      colors: [
                        Color(0xFF0F1E36),
                        Color(0xFF040914),
                        Color(0xFF010308),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Top Header: Back Button, NASA Badge & Language Switcher
            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  // Glowing Sci-Fi Back Button to Welcome / Landing Screen
                  SciFiBackButton(
                    label: isAr ? 'قاعدة لونا' : 'LUNABASE',
                    isAr: isAr,
                    color: primaryColor,
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          NasaFadeRoute(page: const LunabaseWelcomeScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.public, color: primaryColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'NASA // ARTEMIS & MARS 2026',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            fontFamily: 'monospace',
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Language Switcher
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFF334155)),
                      ),
                    ),
                    onPressed: () {
                      AudioSynthService.playButtonClick();
                      ref.read(gameStateProvider.notifier).toggleLanguage();
                    },
                    icon: const Icon(Icons.language, size: 16, color: Color(0xFF38BDF8)),
                    label: Text(
                      isAr ? 'English' : 'العربية',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            // Main Setup Form Box
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF060D1A).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.25),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                      const BoxShadow(
                        color: Colors.black,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
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
                              child: Icon(Icons.badge, color: primaryColor, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? 'بيانات رائد الفضاء والطاقم' : 'CREW ONBOARDING & SETUP',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    isAr
                                        ? 'إعداد ملف الطاقم وتأكيد المساعد الروبوتي'
                                        : 'ASTRONAUT CREDENTIALS & AI COMPANION',
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFF1E293B)),
                        const SizedBox(height: 16),

                        // 1. Astronaut Name
                        Text(
                          isAr ? 'اسم رائد الفضاء:' : "ASTRONAUT FULL NAME:",
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person, color: primaryColor, size: 20),
                            hintText: isAr ? 'أدخل اسمك أو اسم القائد...' : 'e.g. Commander Alex Mercer',
                            hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF030712),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF1E293B)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: primaryColor, width: 1.5),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return isAr ? 'يرجى إدخال اسم رائد الفضاء' : 'Please enter astronaut name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // 2. Call Sign
                        Text(
                          isAr ? 'رمز النداء اللاسلكي (Call Sign):' : "MISSION CALL SIGN:",
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _callSignController,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.tag, color: primaryColor, size: 18),
                            hintText: 'e.g. ARES-1, ORION-LEAD',
                            hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF030712),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF1E293B)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: primaryColor, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 3. Crew Role Selector
                        Text(
                          isAr ? 'التخصص والدور في البعثة:' : "CREW SPECIALTY & ROLE:",
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _roles.map((role) {
                            final roleEn = role['en']!;
                            final isSelected = _selectedRole == roleEn;
                            final prof = _roleProfiles[roleEn] ?? const AstronautProfile();
                            return ChoiceChip(
                              avatar: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.black.withValues(alpha: 0.2) : primaryColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  prof.callSign,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.black : primaryColor,
                                  ),
                                ),
                              ),
                              label: Text(
                                isAr ? role['ar']! : roleEn,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: primaryColor,
                              backgroundColor: const Color(0xFF0F172A),
                              side: BorderSide(
                                color: isSelected ? primaryColor : const Color(0xFF334155),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              onSelected: (_) => _selectRole(roleEn),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),

                        // 4. AI Companion Robot Confirmation ("AEGIS-7")
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF081324),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.smart_toy, color: Color(0xFF38BDF8), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    isAr ? 'المساعد الروبوتي الذكي' : 'AI COMPANION ROBOT',
                                    style: const TextStyle(
                                      color: Color(0xFF38BDF8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'ONLINE // VERIFIED',
                                      style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _robotController,
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                                decoration: InputDecoration(
                                  labelText: isAr ? 'اسم الروبوت المرافق' : 'Companion Robot Designation',
                                  labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                  hintText: 'AEGIS-7',
                                  isDense: true,
                                  filled: true,
                                  fillColor: const Color(0xFF030712),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF1E293B)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 5. Initial Target Planet Selector
                        Text(
                          isAr ? 'وجهة الاستكشاف المبدئية:' : "INITIAL CELESTIAL TARGET:",
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPlanetOption(
                                label: isAr ? 'المريخ' : 'Mars',
                                type: PlanetType.mars,
                                color: const Color(0xFFF97316),
                                icon: Icons.public,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildPlanetOption(
                                label: isAr ? 'القمر' : 'Moon',
                                type: PlanetType.moon,
                                color: const Color(0xFF38BDF8),
                                icon: Icons.nightlight_round,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Launch Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 10,
                            shadowColor: primaryColor.withValues(alpha: 0.6),
                          ),
                          onPressed: _submitAndLaunch,
                          icon: const Icon(Icons.rocket_launch, size: 20),
                          label: Text(
                            isAr ? 'تهيئة الطاقم وبدء المهمة' : 'INITIALIZE CREW & LAUNCH MISSION',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetOption({
    required String label,
    required PlanetType type,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _selectedPlanet == type;
    return InkWell(
      onTap: () {
        AudioSynthService.playButtonClick();
        setState(() => _selectedPlanet = type);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF334155),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : const Color(0xFF94A3B8), size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
