import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/crew_model.dart';
import '../providers/game_state_provider.dart';
import '../services/audio_synth_service.dart';

class CrewCommsModal extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const CrewCommsModal({
    super.key,
    required this.onClose,
  });

  @override
  ConsumerState<CrewCommsModal> createState() => _CrewCommsModalState();
}

class _CrewCommsModalState extends ConsumerState<CrewCommsModal>
    with SingleTickerProviderStateMixin {
  CrewMember? _activeContact;
  String _activeTransmission = '';
  String _activeCode = '';
  bool _isTransmitting = false;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _callCrewMember(CrewMember member) {
    AudioSynthService.playRobotChirp();

    final state = ref.read(gameStateProvider);
    final isAr = state.language.isArabic;
    final currentTask = state.currentTask;

    setState(() {
      _activeContact = member;
      _isTransmitting = true;
      _activeTransmission = isAr ? 'جاري فتح القناة اللاسلكية المشفرة وتوجيه الإشارة...' : 'Acquiring quantum encrypted link...';
      _activeCode = '';
    });

    // Simulate realistic radio delay and response
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      AudioSynthService.playButtonClick();

      // Check if this crew member satisfies active mission task
      final isObjectiveTarget = currentTask != null &&
          currentTask.requiredContactId == member.id &&
          !currentTask.isCompleted;

      if (isObjectiveTarget) {
        ref.read(gameStateProvider.notifier).completeMissionTask(member.id);
        setState(() {
          _isTransmitting = false;
          _activeTransmission = isAr ? currentTask.transmissionDataAr : currentTask.transmissionData;
          _activeCode = currentTask.encryptedCode;
        });
      } else {
        // Personality-specific non-objective responses per crew member
        String transmission;
        String code;

        final siteName = isAr ? state.selectedSite.nameArabic : state.selectedSite.name;
        final vitals = state.telemetry;

        switch (member.id) {
          case 'dr_vance':
            // Planetary Geologist — geology data, spectrometer readings
            transmission = isAr
                ? '${member.nameAr} يستجيب: "القائد! مطياف SHERLOC يقرأ قيم غير عادية من المنطقة المجاورة في $siteName. '
                  'أرى معادن حديدية مع آثار للأوليفين في طبقة أعمق من المتوقع. '
                  'المتحوّل الحراري لا يقل عن 450 درجة مئوية. استهدف الصخور ذات اللون الغامق."'
                : '${member.name}: "Commander, SHERLOC reads anomalous olivine-pyroxene chemistry at $siteName. '
                  'Thermal metamorphism indicators suggest ancient hydrothermal vent activity. '
                  'Collect the dark-toned outcrop samples for Raman spectroscopy. Good hunting!"';
            code = isAr ? 'حالة المطياف: NOMINAL' : 'SPEC-STATUS: NOMINAL';
            break;

          case 'lt_rostova':
            // Avionics Specialist — orbital mechanics, navigation bearing
            transmission = isAr
                ? '${member.nameAr} تستجيب: "أيها القائد! بيانات الملاحة الحالية: '
                  'الارتفاع المداري للمركبة 412 كم، سرعة زاوية 7.9 كم/ث. '
                  'بقي في المنطقة الآمنة — أي تحرك أكثر من 300 متر شمالاً سيدخلك نطاق رياح عاتية."'
                : '${member.name}: "Commander, orbital telemetry nominal. '
                  'Your current position at $siteName is within safe EVA radius. '
                  'Wind shear advisory: ${vitals.surfaceTemperatureC < -50 ? "HIGH" : "LOW"} at current temperature. '
                  'Stay within 300m perimeter and maintain suit heating loop."';
            code = isAr ? 'مسار الملاحة: مستقر' : 'NAV-VECTOR: STABLE';
            break;

          case 'dr_tariq':
            // Astrobiologist — life support vitals, biological safety
            final o2 = vitals.oxygenLevelPercent.toStringAsFixed(1);
            final temp = vitals.surfaceTemperatureC.toStringAsFixed(1);
            transmission = isAr
                ? '${member.nameAr} يستجيب: "أيها القائد! مراقبة دعم الحياة: '
                  'مستوى الأكسجين في البذلة $o2% — ${vitals.oxygenLevelPercent < 85 ? "⚠️ تحذير: مستوى منخفض! عد للمركبة فوراً" : "وضع جيد"}. '
                  'درجة حرارة السطح $temp°م. '
                  'حافظ على ترطيب كافٍ ولا تتجاوز 4 ساعات من السير الفضائي المتواصل."'
                : '${member.name}: "Life support check complete. Suit O2 at $o2% — '
                  '${vitals.oxygenLevelPercent < 85 ? "WARNING: LOW! Return to lander immediately!" : "All nominal."}. '
                  'Surface temp: $temp°C. Biological contamination risk at $siteName: LOW. '
                  'Seal all sample containers before EVA ingress."';
            code = isAr ? 'مستوى الأكسجين: $o2%' : 'LIFE-SUPPORT: O2 $o2%';
            break;

          case 'capcom':
          default:
            // Houston CAPCOM — formal mission control status, all-systems check
            transmission = isAr
                ? '${member.nameAr} يستجيب: "الوضع من مركز التحكم ناسا: جميع الأنظمة المدارية تعمل. '
                  'مهمتك في موقع $siteName موثقة ومسجلة في قاعدة بيانات PDS. '
                  'معدل إرسال البيانات 128 كيلوبت/ث عبر شبكة الفضاء العميق DSN. '
                  'واصل عملك أيها القائد، الأرض تراقبك!"'
                : '${member.name}: "Houston copies. All orbital systems nominal. '
                  'Your EVA data feed from $siteName is being logged in real-time to NASA PDS. '
                  'Deep Space Network link: 99.6% signal integrity at 128 kbps. '
                  'You are go for continued planetary surface operations. The world is watching!"';
            code = isAr ? 'حالة الاتصال: خط مفتوح' : 'DSN-LINK: OPEN // ALL-SYSTEMS-GO';
            break;
        }

        setState(() {
          _isTransmitting = false;
          _activeTransmission = transmission;
          _activeCode = code;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);
    final isAr = state.language.isArabic;
    final primaryColor = state.planet.name == 'mars'
        ? const Color(0xFFF97316)
        : const Color(0xFF38BDF8);
    final currentTask = state.currentTask;

    return Container(
      width: 320,
      height: 480,
      decoration: BoxDecoration(
        color: const Color(0xFF060B14).withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.35),
            blurRadius: 28,
            spreadRadius: 2,
          ),
          const BoxShadow(
            color: Colors.black,
            blurRadius: 18,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                border: Border(bottom: BorderSide(color: primaryColor.withValues(alpha: 0.4))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radio, color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'اللاسلكي المشفر للطاقم' : 'SECURE CREW RADIO COMMS',
                          style: TextStyle(
                            color: primaryColor,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Text(
                          'NASA QUANTUM RELAY // 433.92 MHz',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 8.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      AudioSynthService.playButtonClick();
                      widget.onClose();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.close, color: primaryColor, size: 14),
                    ),
                  ),
                ],
              ),
            ),

            // Active Mission Objective Banner
            if (currentTask != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: currentTask.isCompleted
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          currentTask.isCompleted ? Icons.check_circle : Icons.assignment_late,
                          color: currentTask.isCompleted ? const Color(0xFF10B981) : Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            currentTask.isCompleted
                                ? (isAr ? 'تم إنجاز المهمة (+250 نقطة)' : 'OBJECTIVE COMPLETED (+250 PTS)')
                                : (isAr ? 'المهمة النشطة الحالية:' : 'CURRENT MISSION DIRECTIVE:'),
                            style: TextStyle(
                              color: currentTask.isCompleted ? const Color(0xFF10B981) : Colors.amber,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isAr ? currentTask.titleAr : currentTask.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isAr ? currentTask.descriptionAr : currentTask.description,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 8.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

            // Transmission Display Area (If contact is active)
            if (_activeContact != null)
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1322),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAr ? _activeContact!.nameAr : _activeContact!.name,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _activeContact!.frequency,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 9, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (_isTransmitting)
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return Row(
                            children: [
                              const Icon(Icons.graphic_eq, color: Color(0xFF10B981), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                _activeTransmission,
                                style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontFamily: 'monospace'),
                              ),
                            ],
                          );
                        },
                      )
                    else ...[
                      Text(
                        _activeTransmission,
                        style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 10, height: 1.35),
                      ),
                      if (_activeCode.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF030712),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF10B981)),
                          ),
                          child: Text(
                            'DECRYPTED: $_activeCode',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 9.5,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

            // Crew Members List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                isAr ? 'أفراد طاقم البعثة الفضائية:' : 'MISSION CREW FREQUENCIES:',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: CrewMember.team.length,
                itemBuilder: (context, index) {
                  final member = CrewMember.team[index];
                  final isTarget = currentTask != null &&
                      currentTask.requiredContactId == member.id &&
                      !currentTask.isCompleted;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isTarget
                          ? primaryColor.withValues(alpha: 0.15)
                          : const Color(0xFF0B1424),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isTarget ? primaryColor : const Color(0xFF1E293B),
                        width: isTarget ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E293B),
                            border: Border.all(color: isTarget ? primaryColor : const Color(0xFF475569)),
                          ),
                          child: Icon(Icons.person, size: 14, color: isTarget ? primaryColor : Colors.white70),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isAr ? member.nameAr : member.name,
                                    style: TextStyle(
                                      color: isTarget ? primaryColor : Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (isTarget) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Text(
                                        'TASK CONTACT',
                                        style: TextStyle(color: Colors.black, fontSize: 7, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                isAr ? member.roleAr : member.role,
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 8.5),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isTarget ? primaryColor : const Color(0xFF1E293B),
                            foregroundColor: isTarget ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: () => _callCrewMember(member),
                          icon: const Icon(Icons.call, size: 11),
                          label: Text(
                            isAr ? 'اتصال' : 'RADIO',
                            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold),
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
    );
  }
}


