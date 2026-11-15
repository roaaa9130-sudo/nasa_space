import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_companion_model.dart';
import '../providers/game_state_provider.dart';
import '../services/ai_companion_service.dart';
import '../services/audio_synth_service.dart';

class AiCompanionRobotWidget extends ConsumerStatefulWidget {
  const AiCompanionRobotWidget({super.key});

  @override
  ConsumerState<AiCompanionRobotWidget> createState() => _AiCompanionRobotWidgetState();
}

class _AiCompanionRobotWidgetState extends ConsumerState<AiCompanionRobotWidget>
    with SingleTickerProviderStateMixin {
  bool _isTerminalOpen = false;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AiCompanionMessage> _messages = [];
  late AnimationController _eyePulseController;

  @override
  void initState() {
    super.initState();
    _eyePulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Initial greeting from AEGIS-7
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(gameStateProvider);
      final isAr = state.language.isArabic;
      _messages.add(
        AiCompanionMessage(
          isFromUser: false,
          text: isAr
              ? 'مرحباً يا بطل! 🤖 أنا الروبوت إيجيس-7! هيا نستكشف هذا الكوكب المذهل ونجمع العينات النادرة معاً! 🚀'
              : "Beep-boop! 🤖 I am AEGIS-7, your NASA space robot buddy! Let's explore this awesome planet and find cool samples! 🚀",
        ),
      );
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _eyePulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String query) async {
    if (query.trim().isEmpty) return;
    final state = ref.read(gameStateProvider);
    final isAr = state.language.isArabic;

    AudioSynthService.playButtonClick();

    setState(() {
      _messages.add(AiCompanionMessage(text: query, isFromUser: true));
    });
    _textController.clear();
    _scrollToBottom();

    // Call Regnix AI Cosmo Model with automatic onboard knowledge fallback
    final reply = await AiCompanionService.sendMessage(
      prompt: query,
      planet: state.planet,
      site: state.selectedSite,
      isArabic: isAr,
      distanceToTarget: state.distanceToTarget,
      missionTitle: state.currentTask != null
          ? (isAr ? state.currentTask!.titleAr : state.currentTask!.title)
          : '',
    );

    if (!mounted) return;
    AudioSynthService.playRobotChirp();

    setState(() {
      _messages.add(AiCompanionMessage(text: reply, isFromUser: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);
    final isMars = state.planet.name == 'mars';
    final primaryColor = isMars ? const Color(0xFFF97316) : const Color(0xFF38BDF8);
    final isAr = state.language.isArabic;

    // 1. Closed State: Floating Sci-Fi Robot Companion Badge
    if (!_isTerminalOpen) {
      return AnimatedBuilder(
        animation: _eyePulseController,
        builder: (context, child) {
          final glowAlpha = 0.3 + 0.3 * _eyePulseController.value;
          return InkWell(
            onTap: () {
              AudioSynthService.playRobotChirp();
              setState(() => _isTerminalOpen = true);
            },
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF060D1A).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.5 + 0.3 * _eyePulseController.value),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: glowAlpha),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.7),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Robot Head Avatar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0F172A),
                          border: Border.all(color: primaryColor, width: 1.2),
                        ),
                        child: Icon(Icons.smart_toy, color: primaryColor, size: 20),
                      ),
                      // Antenna Signal Blinker
                      Positioned(
                        top: 1,
                        right: 2,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF10B981),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF10B981), blurRadius: 4, spreadRadius: 1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.astronaut.robotName} AI',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        isAr ? 'مساعد ناسا العلمي' : 'NASA SCIENCE BOT',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // 2. Open State: Full NASA AI Companion Scientific Terminal
    return Container(
      width: 340,
      height: 440,
      decoration: BoxDecoration(
        color: const Color(0xFF060E1E).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Terminal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1729),
                border: Border(bottom: BorderSide(color: primaryColor.withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.15),
                      border: Border.all(color: primaryColor, width: 1),
                    ),
                    child: Icon(Icons.smart_toy, color: primaryColor, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'المساعد العلمي ريجنيكس AEGIS-7' : 'AEGIS-7 // REGNIX AI SCIENTIFIC ASSISTANT',
                          style: TextStyle(
                            color: primaryColor,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${state.planet.displayName.toUpperCase()} // REGNIX COSMO-ALPHA-V2 // ONLINE',
                          style: const TextStyle(
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
                      setState(() => _isTerminalOpen = false);
                    },
                    borderRadius: BorderRadius.circular(10),
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

            // Quick Topic Suggestion Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: const Color(0xFF040A14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChip(
                      label: isAr ? '💧 دلائل المياه والجليد' : '💧 Water & Ice',
                      query: isAr ? 'ما هي أدلة وجود المياه أو الجليد هنا؟' : 'Analyze water and ice signatures at this site',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(width: 6),
                    _buildChip(
                      label: isAr ? '🪨 تحليل الصخور والتربة' : '🪨 Soil & Rocks',
                      query: isAr ? 'حلل التركيب الجيولوجي للصخور والتربة' : 'Analyze geology, rocks, and soil composition',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(width: 6),
                    _buildChip(
                      label: isAr ? '🌪️ الغلاف الجوي والإشعاع' : '🌪️ Atmosphere & Rad',
                      query: isAr ? 'ما هي مستويات الضغط الجوي والإشعاع؟' : 'Atmospheric pressure and radiation safety report',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(width: 6),
                    _buildChip(
                      label: isAr ? '🎯 الأهداف العلمية' : '🎯 Mission Protocols',
                      query: isAr ? 'ما هي أهداف المهمة العلمية الرئيسية؟' : 'What are the primary NASA scientific objectives?',
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),
            ),

            // Messages Chat Log
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.isFromUser;
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      constraints: const BoxConstraints(maxWidth: 270),
                      decoration: BoxDecoration(
                        color: isUser
                            ? primaryColor.withValues(alpha: 0.25)
                            : const Color(0xFF0F1E33),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isUser ? primaryColor : const Color(0xFF1E3A5F),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUser ? Icons.person : Icons.smart_toy,
                                size: 10,
                                color: isUser ? Colors.white70 : primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isUser ? (isAr ? 'الرائد' : 'ASTRONAUT') : 'AEGIS-7',
                                style: TextStyle(
                                  color: isUser ? Colors.white70 : primaryColor,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg.text,
                            style: const TextStyle(
                              color: Color(0xFFF1F5F9),
                              fontSize: 10.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFF081220),
                border: Border(top: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                      decoration: InputDecoration(
                        hintText: isAr ? 'اسأل الروبوت AEGIS-7...' : 'Ask AEGIS-7 about terrain...',
                        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: const Color(0xFF030712),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF334155)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => _sendMessage(_textController.text),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.send, color: Colors.black, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required String query,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: () => _sendMessage(query),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E33),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 0.8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: primaryColor,
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

