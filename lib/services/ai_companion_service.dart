import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ai_companion_model.dart';
import '../models/planet_mission.dart';

/// Regnix AI & NASA Scientific Companion Service (AEGIS-7)
/// High-throughput streaming and REST assistant powered by Cosmo Alpha Engine
class AiCompanionService {
  static const String apiKey = 'cosmo_opDsi1E5wRpTSzEhkSe7M989tvL1Qie4IRL5j9MCXtM';
  static const String model = 'cosmo-alpha-v2';
  static const String endpoint = 'https://api.regnix.ai/v1/chat/completions';
  static const Duration timeout = Duration(milliseconds: 4500);

  /// Send prompt to Regnix AI Cosmo Model with seamless offline-safe fallback
  static Future<String> sendMessage({
    required String prompt,
    required PlanetType planet,
    required LandingSite site,
    required bool isArabic,
    double distanceToTarget = 0.0,
    String missionTitle = '',
  }) async {
    final systemPrompt = isArabic
        ? 'أنت AEGIS-7، الروبوت الذكي المساعد لرواد فضاء ناسا على كوكب ${planet.displayName} في موقع ${site.name}. ردودك علمية، ملهمة، ومباشرة ومرحة وموجزة.'
        : 'You are AEGIS-7, the intelligent NASA science robot companion on ${planet.displayName} at site ${site.name}. Your responses are scientifically accurate, inspiring, concise, and helpful.';

    try {
      debugPrint('🤖 [REGNIX AI] Dispatching query to $model: "$prompt"');

      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.7,
              'max_tokens': 160,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map && data.containsKey('choices')) {
          final choices = data['choices'] as List?;
          if (choices != null && choices.isNotEmpty) {
            final text = choices[0]['message']?['content']?.toString().trim();
            if (text != null && text.isNotEmpty) {
              debugPrint('✅ [REGNIX AI] Response received successfully: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
              return text;
            }
          }
        }
      }
      debugPrint('⚠️ [REGNIX AI] API returned status ${response.statusCode}. Activating local AI knowledge base...');
    } catch (e) {
      debugPrint('⚠️ [REGNIX AI] Connection notice ($e). Seamlessly deploying onboard knowledge base.');
    }

    // 100% Guaranteed Onboard Local Scientific Assistant Fallback
    return AiCompanionKnowledgeBase.queryAssistant(
      prompt: prompt,
      planet: planet,
      site: site,
      isArabic: isArabic,
      distanceToTarget: distanceToTarget,
      missionTitle: missionTitle,
    );
  }
}
