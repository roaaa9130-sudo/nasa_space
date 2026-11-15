enum PlanetType {
  mars,
  moon;

  String get displayName => this == PlanetType.mars ? 'Mars' : 'Moon';
  String get displayArabic => this == PlanetType.mars ? 'المريخ' : 'القمر';
}

enum MissionPhase {
  orbitalRecon,
  descentTrajectory,
  surfaceExploration,
  docked;

  String get label => switch (this) {
    MissionPhase.orbitalRecon => 'Orbital Reconnaissance',
    MissionPhase.descentTrajectory => 'Terminal Descent',
    MissionPhase.surfaceExploration => 'Surface Exploration',
    MissionPhase.docked => 'Orbital Station Docked',
  };

  String get labelArabic => switch (this) {
    MissionPhase.orbitalRecon => 'الاستطلاع المداري',
    MissionPhase.descentTrajectory => 'الهبوط النهائي',
    MissionPhase.surfaceExploration => 'استكشاف السطح',
    MissionPhase.docked => 'الرسو بالمحطة المدارية',
  };
}

class LandingSite {
  final String id;
  final String name;
  final String nameArabic;
  final PlanetType planet;
  final double latitude;
  final double longitude;
  final double elevationKm;
  final double hazardRating; // 0.0 to 1.0
  final String description;
  final String descriptionArabic;
  final List<String> scientificGoals;
  final List<String> scientificGoalsArabic;

  const LandingSite({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.planet,
    required this.latitude,
    required this.longitude,
    required this.elevationKm,
    required this.hazardRating,
    required this.description,
    required this.descriptionArabic,
    required this.scientificGoals,
    required this.scientificGoalsArabic,
  });

  String get coordinateString =>
      '${latitude >= 0 ? latitude.toStringAsFixed(2) : (-latitude).toStringAsFixed(2)}°${latitude >= 0 ? 'N' : 'S'}, '
      '${longitude >= 0 ? longitude.toStringAsFixed(2) : (-longitude).toStringAsFixed(2)}°${longitude >= 0 ? 'E' : 'W'}';
}

class TelemetryData {
  final double altitudeKm;
  final double velocityKmh;
  final double atmosphericPressureKpa;
  final double surfaceTemperatureC;
  final double radiationMsvPerHour;
  final double oxygenLevelPercent;
  final double waterLevelPercent;
  final double suitPowerPercent;
  final double fuelLevelPercent;
  final double pitchDeg;
  final double rollDeg;
  final double headingDeg;
  final bool rcsThrustersActive;

  const TelemetryData({
    required this.altitudeKm,
    required this.velocityKmh,
    required this.atmosphericPressureKpa,
    required this.surfaceTemperatureC,
    required this.radiationMsvPerHour,
    required this.oxygenLevelPercent,
    required this.waterLevelPercent,
    required this.suitPowerPercent,
    required this.fuelLevelPercent,
    required this.pitchDeg,
    required this.rollDeg,
    required this.headingDeg,
    required this.rcsThrustersActive,
  });

  TelemetryData copyWith({
    double? altitudeKm,
    double? velocityKmh,
    double? atmosphericPressureKpa,
    double? surfaceTemperatureC,
    double? radiationMsvPerHour,
    double? oxygenLevelPercent,
    double? waterLevelPercent,
    double? suitPowerPercent,
    double? fuelLevelPercent,
    double? pitchDeg,
    double? rollDeg,
    double? headingDeg,
    bool? rcsThrustersActive,
  }) {
    return TelemetryData(
      altitudeKm: altitudeKm ?? this.altitudeKm,
      velocityKmh: velocityKmh ?? this.velocityKmh,
      atmosphericPressureKpa: atmosphericPressureKpa ?? this.atmosphericPressureKpa,
      surfaceTemperatureC: surfaceTemperatureC ?? this.surfaceTemperatureC,
      radiationMsvPerHour: radiationMsvPerHour ?? this.radiationMsvPerHour,
      oxygenLevelPercent: oxygenLevelPercent ?? this.oxygenLevelPercent,
      waterLevelPercent: waterLevelPercent ?? this.waterLevelPercent,
      suitPowerPercent: suitPowerPercent ?? this.suitPowerPercent,
      fuelLevelPercent: fuelLevelPercent ?? this.fuelLevelPercent,
      pitchDeg: pitchDeg ?? this.pitchDeg,
      rollDeg: rollDeg ?? this.rollDeg,
      headingDeg: headingDeg ?? this.headingDeg,
      rcsThrustersActive: rcsThrustersActive ?? this.rcsThrustersActive,
    );
  }

  static TelemetryData defaultForPlanet(PlanetType planet) {
    if (planet == PlanetType.mars) {
      return const TelemetryData(
        altitudeKm: 384.2,
        velocityKmh: 24120.0,
        atmosphericPressureKpa: 0.636,
        surfaceTemperatureC: -62.5,
        radiationMsvPerHour: 0.28,
        oxygenLevelPercent: 94.6,
        waterLevelPercent: 91.2,
        suitPowerPercent: 98.4,
        fuelLevelPercent: 88.0,
        pitchDeg: -4.2,
        rollDeg: 1.1,
        headingDeg: 84.0,
        rcsThrustersActive: false,
      );
    } else {
      return const TelemetryData(
        altitudeKm: 112.5,
        velocityKmh: 5880.0,
        atmosphericPressureKpa: 0.000,
        surfaceTemperatureC: -175.0,
        radiationMsvPerHour: 1.35,
        oxygenLevelPercent: 98.2,
        waterLevelPercent: 95.0,
        suitPowerPercent: 99.1,
        fuelLevelPercent: 91.5,
        pitchDeg: 0.5,
        rollDeg: -0.8,
        headingDeg: 180.0,
        rcsThrustersActive: false,
      );
    }
  }
}

// Preset Landing Sites Catalog
class PlanetaryCatalog {
  static const List<LandingSite> marsSites = [
    LandingSite(
      id: 'jezero',
      name: 'Jezero Crater',
      nameArabic: 'فوهة جيزيرو',
      planet: PlanetType.mars,
      latitude: 18.38,
      longitude: 77.58,
      elevationKm: -2.5,
      hazardRating: 0.38,
      description: 'Ancient river delta lakebed rich in clay minerals, ideal for astrobiological biosignature detection.',
      descriptionArabic: 'قاع بحيرة ودلتا نهر قديمة غنية بمعادن الطين، مثالية للبحث عن علامات الحياة القديمة.',
      scientificGoals: ['Biosignature sampling', 'Sediment core extraction', 'Subsurface radar sounding'],
      scientificGoalsArabic: ['أخذ عينات البصمات الحيوية', 'استخراج عينات الرواسب', 'المسح الراداري تحت السطح'],
    ),
    LandingSite(
      id: 'olympus',
      name: 'Olympus Mons Caldera',
      nameArabic: 'بركان أوليمبوس مونس',
      planet: PlanetType.mars,
      latitude: 18.65,
      longitude: 226.2,
      elevationKm: 21.9,
      hazardRating: 0.72,
      description: 'The largest shield volcano in the Solar System, towering three times the height of Mount Everest.',
      descriptionArabic: 'أكبر بركان درعي في المجموعة الشمسية، يبلغ ارتفاعه ثلاثة أضعاف قمة إفرست.',
      scientificGoals: ['Lava tube exploration', 'Volcanic geology profiling', 'Atmospheric thinning analysis'],
      scientificGoalsArabic: ['استكشاف أنابيب الحمم البركانية', 'تحليل الجيولوجيا البركانية', 'دراسة تخلخل الغلاف الجوي'],
    ),
    LandingSite(
      id: 'valles_marineris',
      name: 'Valles Marineris',
      nameArabic: 'وادي مارينر العظيم',
      planet: PlanetType.mars,
      latitude: -13.9,
      longitude: 300.8,
      elevationKm: -7.0,
      hazardRating: 0.65,
      description: 'Vast canyon system stretching 4,000 km, revealing deep Martian tectonic fault strata.',
      descriptionArabic: 'نظام أخدودي عملاق يمتد لأكثر من 4000 كم، يكشف طبقات الصفائح التكتونية العميقة للمريخ.',
      scientificGoals: ['Deep canyon wall mapping', 'Hydrated sulfate analysis', 'Wind erosion tracking'],
      scientificGoalsArabic: ['رسم خرائط جدران الأخدود العميقة', 'تحليل الكبريتات المائية', 'تتبع التعرية الهوائية'],
    ),
    LandingSite(
      id: 'gale',
      name: 'Gale Crater',
      nameArabic: 'فوهة غيل',
      planet: PlanetType.mars,
      latitude: -4.58,
      longitude: 137.44,
      elevationKm: -4.5,
      hazardRating: 0.28,
      description: 'Impact crater featuring Mount Sharp (Aeolis Mons), providing billions of years of layered Martian climate history.',
      descriptionArabic: 'فوهة اصطدامية يتوسطها جبل شارب، تقدم سجلاً لمليارات السنين من تاريخ مناخ المريخ.',
      scientificGoals: ['Paleo-lake chemistry', 'Organic carbon detection', 'Radiation shielding metrics'],
      scientificGoalsArabic: ['كيمياء البحيرات القديمة', 'الكشف عن الكربون العضوي', 'قياسات تدريع الإشعاع'],
    ),
  ];

  static const List<LandingSite> moonSites = [
    LandingSite(
      id: 'shackleton',
      name: 'Shackleton Crater (South Pole)',
      nameArabic: 'فوهة شاكلتون (القطب الجنوبي)',
      planet: PlanetType.moon,
      latitude: -89.9,
      longitude: 0.0,
      elevationKm: -4.2,
      hazardRating: 0.58,
      description: 'Permanently shadowed lunar crater harboring massive deposits of water-ice reserves for Artemis III base.',
      descriptionArabic: 'فوهة قمرية مظللة باستمرار تحتوي على رواسب هائلة من جليد الماء لقاعدة أرتميس 3.',
      scientificGoals: ['Water-ice core drilling', 'Perpetual light rim power base', 'Cryogenic volatile collection'],
      scientificGoalsArabic: ['الحفر الاستكشافي لجليد الماء', 'إنشاء قاعدة طاقة شمسية مستمرة على الحافة', 'جمع الغازات المتطايرة المجمدة'],
    ),
    LandingSite(
      id: 'tranquillity',
      name: 'Mare Tranquillitatis (Apollo 11)',
      nameArabic: 'بحر الهدوء (أبولو 11)',
      planet: PlanetType.moon,
      latitude: 0.67,
      longitude: 23.47,
      elevationKm: -1.2,
      hazardRating: 0.15,
      description: 'Historic Apollo 11 landing site. Smooth basaltic mare plains rich in titanium and regolith minerals.',
      descriptionArabic: 'الموقع التاريخي لهبوط أبولو 11. سهول بازلتية منبسطة غنية بالتيتانيوم ومعادن الثرى الشمسي.',
      scientificGoals: ['Historical artifact survey', 'Titanium basalt extraction', 'Micrometeorite impact frequency'],
      scientificGoalsArabic: ['فحص الآثار التاريخية للهبوط', 'استخراج خامات التيتانيوم', 'دراسة تواتر النيازك الدقيقة'],
    ),
    LandingSite(
      id: 'copernicus',
      name: 'Copernicus Crater',
      nameArabic: 'فوهة كوبرنيكوس',
      planet: PlanetType.moon,
      latitude: 9.62,
      longitude: 339.92,
      elevationKm: -3.8,
      hazardRating: 0.44,
      description: 'Prominent lunar ray crater with sharp terraced walls and towering central peaks.',
      descriptionArabic: 'فوهة شعاعية بارزة تتميز بجدران مدرجة حادة وقمم مركزية شاهقة.',
      scientificGoals: ['Central peak petrology', 'Impact melt sheet analysis', 'Ejecta ray composition'],
      scientificGoalsArabic: ['دراسة صخور القمة المركزية', 'تحليل صفائح صهارة الارتطام', 'فحص مكونات المقذوفات'],
    ),
    LandingSite(
      id: 'south_pole_aitken',
      name: 'South Pole-Aitken (Malapert Mountain)',
      nameArabic: 'حوض أيتكين (جبل مالابرت)',
      planet: PlanetType.moon,
      latitude: -85.9,
      longitude: 12.9,
      elevationKm: 5.0,
      hazardRating: 0.62,
      description: 'Deepest impact basin on the Moon with perpetual solar peaks, providing ideal vantage for long-range Artemis relays.',
      descriptionArabic: 'أعمق حوض اصطدام على القمر ذو قمم مضاءة باستمرار، يوفر موقعاً استراتيجياً لمحطات طاقة أرتميس واستكشاف صخور الوشاح.',
      scientificGoals: ['Deep lunar mantle petrology', 'Perpetual solar power array deployment', 'Far-side radio astronomy relay'],
      scientificGoalsArabic: ['دراسة صخور الوشاح القمري العميق', 'نشر مصفوفات الطاقة الشمسية الدائمة', 'محطة اتصالات تلسكوب الجانب البعيد'],
    ),
  ];

  static List<LandingSite> getSitesFor(PlanetType planet) {
    return planet == PlanetType.mars ? marsSites : moonSites;
  }
}
