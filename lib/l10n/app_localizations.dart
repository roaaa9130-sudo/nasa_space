import 'package:flutter/material.dart';

enum AppLanguage {
  english('en', 'English'),
  arabic('ar', 'العربية');

  final String code;
  final String label;
  const AppLanguage(this.code, this.label);

  bool get isArabic => this == AppLanguage.arabic;
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;
}

class AppStrings {
  final AppLanguage language;
  const AppStrings(this.language);

  bool get isAr => language.isArabic;

  // General App & NASA Headers
  String get appTitle => isAr
      ? 'استكشاف المريخ والقمر 3D - ناسا 2026'
      : 'NASA 3D Mars & Moon Exploration (2026)';
  String get nasaAgency => isAr ? 'الإدارة الوطنية للملاحة الجوية والفضاء (ناسا)' : 'National Aeronautics and Space Administration';
  String get missionProgram => isAr ? 'برنامج أرتميس وبيرسيفيرانس للاستكشاف' : 'Artemis & Perseverance Deep Space Program';

  // Navigation
  String get orbitalSurvey => isAr ? 'المسح المداري' : 'Orbital Survey';
  String get landingCoordinates => isAr ? 'إحداثيات الهبوط الدقيقة' : 'Precision Landing';
  String get cockpitHUD => isAr ? 'قمرة القيادة والتوجيه' : 'Cockpit HUD';
  String get surfaceRecon => isAr ? 'استكشاف السطح' : 'Surface Recon';
  String get settings => isAr ? 'الإعدادات' : 'Settings';
  String get backToOrbit => isAr ? 'العودة للمدار' : 'Back to Orbit';
  String get mainMenu => isAr ? 'القائمة الرئيسية' : 'Main Menu';

  // Planets
  String get selectCelestialBody => isAr ? 'اختر الجرم السماوي' : 'Select Celestial Body';
  String get marsTitle => isAr ? 'المريخ (الكوكب الأحمر)' : 'Mars (The Red Planet)';
  String get moonTitle => isAr ? 'القمر (لونا)' : 'The Moon (Luna)';
  String get marsDesc => isAr
      ? 'رابع الكواكب بُعداً عن الشمس. يتميز بغلاف جوي رقيق من ثاني أكسيد الكربون، وتضاريس بركانية وأودية عملاقة.'
      : 'Fourth planet from the Sun. Featuring a thin CO2 atmosphere, towering volcanoes, and immense canyon networks.';
  String get moonDesc => isAr
      ? 'التابع الطبيعي الوحيد للأرض. فراغ كامل وتضاريس غنية بفوهات الاصطدام ورواسب الجليد المائي في القطب الجنوبي.'
      : "Earth's only natural satellite. A pristine vacuum featuring ancient impact craters and volatile water-ice deposits.";

  // Landing Screen
  String get landingSiteSelection => isAr ? 'تحديد موقع الهبوط الدقيق' : 'Precision Landing Site Selection';
  String get targetCoordinates => isAr ? 'إحداثيات الهدف:' : 'Target Coordinates:';
  String get elevation => isAr ? 'الارتفاع الطبوغرافي:' : 'Elevation:';
  String get hazardRating => isAr ? 'مؤشر خطورة الهبوط:' : 'Landing Hazard Rating:';
  String get scientificObjectives => isAr ? 'الأهداف العلمية:' : 'Scientific Objectives:';
  String get initiateDescent => isAr ? 'بدء مناورة الهبوط النهائي' : 'Initiate Terminal Descent';
  String get travelOrLandHere => isAr ? 'الانتقال / الهبوط هنا' : 'Travel / Land Here';
  String get selectPinInstruction => isAr ? 'انقر على أي نقطة 3D على الكوكب للاستكشاف' : 'Click any 3D pin on the globe to explore';
  String get orbitGridToggle => isAr ? 'شبكة الإحداثيات المدارية' : 'Orbital Coordinate Grid';
  String get autoRotationToggle => isAr ? 'الدوران التلقائي' : 'Auto Rotation';
  String get lockTarget => isAr ? 'تثبيت الهدف' : 'Target Locked';

  // Telemetry & Watch HUD
  String get telemetryWatchHUD => isAr ? 'ساعة القياس عن بُعد الهولوغرافية' : 'Holographic Watch HUD Telemetry';
  String get vitalTelemetry => isAr ? 'مؤشرات الدعم الحيوي' : 'Astronaut Vitals HUD';
  String get oxygen => isAr ? 'الأكسجين' : 'Oxygen';
  String get water => isAr ? 'المياه' : 'Water';
  String get suitPower => isAr ? 'طاقة البذلة' : 'Suit Power';
  String get altitude => isAr ? 'الارتفاع المداري' : 'Orbital Altitude';
  String get velocity => isAr ? 'السرعة المتجهة' : 'Orbital Velocity';
  String get atmosphericPressure => isAr ? 'الضغط الجوي' : 'Atmospheric Pressure';
  String get surfaceTemp => isAr ? 'درجة حرارة السطح' : 'Surface Temp';
  String get radiationFlux => isAr ? 'تدفق الإشعاع الشمسي' : 'Radiation Flux';
  String get oxygenLifeSupport => isAr ? 'خزان الأكسجين ودعم الحياة' : 'Oxygen & Life Support';
  String get reactionControlSystem => isAr ? 'محركات التوجيه النفاثة (RCS)' : 'RCS Propellant / Thrusters';
  String get artificialHorizon => isAr ? 'أفق الاتزان الجيروسكوبي' : 'Artificial Horizon Gyro';
  String get fireThruster => isAr ? 'إطلاق نفاثات التعديل' : 'Pulse RCS Thrusters';
  String get thrusterActive => isAr ? 'النفاثات قيد الاشتعال' : 'Thrusters Firing';
  String get thrusterStandby => isAr ? 'النفاثات في وضع الاستعداد' : 'Thrusters Standby';

  // Cockpit Controls
  String get flightSystemsStatus => isAr ? 'حالة أنظمة الملاحة الفضائية' : 'Flight Systems Status';
  String get allSystemsNominal => isAr ? 'كافة الأنظمة تعمل بكفاءة تامة' : 'ALL SYSTEMS NOMINAL';
  String get autonomousNavigation => isAr ? 'الملاحة الذاتية' : 'Auto Navigation';
  String get manualOverride => isAr ? 'التحكم اليدوي' : 'Manual Override';
  String get radarTracking => isAr ? 'الرادار الكهرومغناطيسي' : 'Electromagnetic Radar';
  String get switchExplorationMode => isAr ? 'تبديل وضع الاستكشاف (سطحي / مداري)' : 'Switch Mode (Surface / Orbit)';

  // Surface Recon
  String get roverSpeed => isAr ? 'سرعة المركبة' : 'Rover Speed';
  String get roverHeading => isAr ? 'الاتجاه والبوصلة' : 'Rover Heading';
  String get spectrometerAnalysis => isAr ? 'تحليل المطياف الصخري' : 'Spectrometer Analysis';
  String get waterIceSignature => isAr ? 'بصمة جليد الماء' : 'Water-Ice Signature';
  String get driveInstructions => isAr ? 'استخدم أزرار التحكم أو لوحة المفاتيح لقيادة المركبة' : 'Use on-screen buttons or W/A/S/D to drive rover';

  // Buttons & Status
  String get launchMission => isAr ? 'إطلاق الرحلة الفضائية' : 'Launch Deep Space Mission';
  String get switchLanguage => isAr ? 'English' : 'العربية';
  String get audioToggle => isAr ? 'الصوت الفضائي' : 'Space Audio';

  // Hardware Smartwatch & Vitals Alarms
  String get smartwatchTitle => isAr ? 'ساعة رائد الفضاء الذكية (EVA-X7)' : 'NASA EVA-X7 Smartwatch';
  String get criticalAlarmO2 => isAr ? 'إنذار حرج: مستوى الأكسجين منخفض جداً!' : 'CRITICAL ALARM: O2 RESERVES COMPROMISED!';
  String get criticalAlarmPower => isAr ? 'تحذير: طاقة بطارية البذلة أقل من 25%!' : 'WARNING: SUIT BATTERY BELOW 25%!';
  String get criticalAlarmRad => isAr ? 'خطر: تدفق إشعاعي مرتفع في المنطقة!' : 'DANGER: HIGH RADIATION FLUX DETECTED!';
  String get replenishO2 => isAr ? 'تعبئة الأكسجين الطارئ' : 'Emergency O2 Boost';
  String get rechargePower => isAr ? 'إعادة شحن بطارية البذلة' : 'Recharge Suit Battery';
  String get testAlarm => isAr ? 'محاكاة إنذار حرج' : 'Simulate Low Vitals';

  // Spacecraft Boarding & Descent
  String get boardingInitiated => isAr ? 'صعود رائد الفضاء للمركبة وإغلاق غرفة الضغط' : 'Astronaut Boarding Starship // Hatch Sealed';
  String get deorbitBurn => isAr ? 'اشتعال محركات الدفع وتعديل مسار الدخول' : 'De-orbit Burn Trajectory Armed';
  String get terminalDescent => isAr ? 'الهبوط النهائي والكبح العكسي النشط' : 'Terminal Braking & Retro-Propulsion';
  String get touchdownSuccess => isAr ? 'تم الهبوط بنجاح على السطح // نشر الرامب' : 'Touchdown Confirmed // Deployed Surface Mode';
  String get skipDescent => isAr ? 'تخطي المشهد' : 'Skip Sequence';

  // AI Robot Companion
  String get aiCompanionName => isAr ? 'الروبوت المساعد الذكي (AEGIS-7)' : 'AI Companion Robot (AEGIS-7)';
  String get askAiPrompt => isAr ? 'اسأل المساعد الذكي عن التضاريس والعلوم...' : 'Ask NASA AI Robot about terrain & science...';
  String get aiRobotStatus => isAr ? 'الذكاء الاصطناعي متصل بقاعدة بيانات ناسا المفتوحة' : 'AI Online // NASA Open Science Telemetry';

  // Surface Exploration HUD & Controls (Requirements 3, 4, 6)
  String get totalScore => isAr ? 'مجموع النقاط الإجمالي' : 'Total Score';
  String get systemTelemetryMenu => isAr ? 'بيانات النظام والملاحة' : 'System & Telemetry';
  String get missionObjectivesMenu => isAr ? 'المهام والأهداف والملاحة' : 'Mission Objectives';
  String get distanceToTarget => isAr ? 'المسافة للهدف العلمي' : 'Distance to Sample';
  String get samplesCollected => isAr ? 'العينات المجموعة' : 'Samples Collected';
  String get collectSample => isAr ? 'جمع العينة الفضائية' : 'Collect Sample';
  String get sampleCollectedSuccess => isAr ? 'تم جمع العينة بنجاح (+250 نقطة)!' : 'Sample Collected (+250 XP)!';
  String get sampleTooFar => isAr ? 'اقترب لمسافة أقل من 3 أمتار لجمع العينة' : 'Get within 3 meters to collect';
  String get astronautMovement => isAr ? 'حركة رائد الفضاء' : 'Astronaut Movement';
  String get crewCommsRadio => isAr ? 'التواصل مع الطاقم' : 'Crew Comms / Radio';
  String get missionDebriefing => isAr ? 'التقرير الختامي للبعثة' : 'Mission Debriefing';
  String get returnToLandingSites => isAr ? 'العودة لاختيار مواقع الهبوط' : 'Return to Landing Sites';
  String get missionDebriefSummary => isAr ? 'ملخص أداء رائد الفضاء والنتائج العلمية' : 'EVA Performance & Scientific Findings';
  String get walkInstructions => isAr ? 'استخدم أزرار الأسهم أو W/A/S/D لتحريك رائد الفضاء' : 'Use directional arrows or W/A/S/D to move astronaut';
  String get debriefMissionComplete => isAr ? 'اكتملت الجولة الاستكشافية بنجاح' : 'EVA Exploration Mission Completed';
}
