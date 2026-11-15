import '../models/planet_mission.dart';

class AiCompanionMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final String? topicTag;

  AiCompanionMessage({
    required this.text,
    required this.isFromUser,
    DateTime? timestamp,
    this.topicTag,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiCompanionKnowledgeBase {
  static String queryAssistant({
    required String prompt,
    required PlanetType planet,
    required LandingSite site,
    required bool isArabic,
    double distanceToTarget = 0.0,
    String missionTitle = '',
  }) {
    final lower = prompt.toLowerCase();

    // 0. Navigation / Direction / Target / Beacon queries
    if (lower.contains('where') ||
        lower.contains('أين') ||
        lower.contains('direction') ||
        lower.contains('اتجاه') ||
        lower.contains('target') ||
        lower.contains('هدف') ||
        lower.contains('beacon') ||
        lower.contains('منارة') ||
        lower.contains('sample') ||
        lower.contains('عينة') ||
        lower.contains('distance') ||
        lower.contains('مسافة')) {
      final dist = distanceToTarget.toStringAsFixed(1);
      return isArabic
          ? 'المنارة المشعة تبعد $dist متر فقط أمامك! 🎯 اتبع الضوء الذهبي واجمع العينة!'
          : 'Target beacon is just ${dist}m ahead! 🎯 Follow the golden light and grab the sample!';
    }

    // 1. Water & Ice Queries
    if (lower.contains('water') ||
        lower.contains('ice') ||
        lower.contains('ماء') ||
        lower.contains('جليد') ||
        lower.contains('مياه')) {
      if (planet == PlanetType.moon) {
        return isArabic
          ? 'اكتشاف رائع! ❄️ يوجد جليد مائي نقي داخل الفوهات المظلمة، سنصنع منه ماءً ووقوداً!'
          : 'Awesome find! ❄️ Pure water ice is hiding in dark craters, perfect for astronaut rocket fuel!';
      } else {
        return isArabic
          ? 'مرحى يا بطل! 💧 وجدنا آثار أنهار وبحيرات قديمة كانت تتدفق هنا قبل مليارات السنين!'
          : 'Yay, explorer! 💧 Ancient riverbeds here prove water flowed on Mars billions of years ago!';
      }
    }

    // 2. Soil, Regolith & Geology
    if (lower.contains('soil') ||
        lower.contains('regolith') ||
        lower.contains('rock') ||
        lower.contains('تربة') ||
        lower.contains('صخور') ||
        lower.contains('جيولوجيا')) {
      if (planet == PlanetType.moon) {
        return isArabic
          ? 'صخور قمرية مذهلة! 🪨 الغبار القمري ناعم ولامع، ويمكننا استخراج الأكسجين منه!'
          : 'Super cool space rocks! 🪨 Lunar dust is packed with minerals we can turn into fresh oxygen!';
      } else {
        return isArabic
          ? 'رمال وصخور حمراء براقة! 🔴 صدأ الحديد يمنح المريخ لونه المميز والجميل!'
          : 'Sparkly red Martian soil! 🔴 Iron rust gives the Red Planet its awesome superhero color!';
      }
    }

    // 3. Atmosphere, Pressure & Radiation
    if (lower.contains('atmosphere') ||
        lower.contains('pressure') ||
        lower.contains('radiation') ||
        lower.contains('غلاف') ||
        lower.contains('ضغط') ||
        lower.contains('إشعاع') ||
        lower.contains('طقس') ||
        lower.contains('weather')) {
      if (planet == PlanetType.moon) {
        return isArabic
          ? 'لا تقلق أبداً! 🛡️ بذلتك الفضائية الخارقة تحميك من الفراغ والإشعاع تماماً!'
          : 'No worries at all! 🛡️ Your high-tech NASA suit shields you from space vacuum perfectly!';
      } else {
        return isArabic
          ? 'الطقس بارد لكن ممتع! 🚀 درعك الفضائي يمدك بالأكسجين النقي والحرارة المثالية!'
          : 'Chilly winds outside! 🚀 But your awesome spacesuit keeps you warm with 100% fresh oxygen!';
      }
    }

    // 4. Anomaly & Mission Protocols
    if (lower.contains('anomaly') ||
        lower.contains('mission') ||
        lower.contains('objective') ||
        lower.contains('مهمة') ||
        lower.contains('شذوذ') ||
        lower.contains('هدف') ||
        lower.contains('خطة')) {
      return isArabic
        ? 'مهمتك اليوم: اتبع المنارة المشعة، اجمع العينات النادرة، وسجل نقاطاً جديدة! 🏆'
        : 'Your mission: Follow the glowing beacon, collect rare samples, and earn bonus XP! 🏆';
    }

    // Default friendly kid response
    return isArabic
      ? 'أنا معك خطوة بخطوة يا كابتن! 🚀 اسألني عن الماء، الصخور، أو اتجاه المنارة المشعة!'
      : 'I am right beside you, Captain! 🚀 Ask me about water-ice, space rocks, or finding the beacon!';
  }
}
