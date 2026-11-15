import 'planet_mission.dart';

class AstronautProfile {
  final String name;
  final String callSign;
  final String role;
  final String roleArabic;
  final String robotName;
  final String clearanceLevel;

  const AstronautProfile({
    this.name = 'Commander Alex Mercer',
    this.callSign = 'ARES-1',
    this.role = 'Mission Commander',
    this.roleArabic = 'قائد البعثة الفضائية',
    this.robotName = 'AEGIS-7',
    this.clearanceLevel = 'NASA LEVEL-5 TOP SECRET',
  });

  AstronautProfile copyWith({
    String? name,
    String? callSign,
    String? role,
    String? roleArabic,
    String? robotName,
    String? clearanceLevel,
  }) {
    return AstronautProfile(
      name: name ?? this.name,
      callSign: callSign ?? this.callSign,
      role: role ?? this.role,
      roleArabic: roleArabic ?? this.roleArabic,
      robotName: robotName ?? this.robotName,
      clearanceLevel: clearanceLevel ?? this.clearanceLevel,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'callSign': callSign,
    'role': role,
    'roleArabic': roleArabic,
    'robotName': robotName,
    'clearanceLevel': clearanceLevel,
  };

  factory AstronautProfile.fromJson(Map<dynamic, dynamic> json) => AstronautProfile(
    name: json['name'] as String? ?? 'Commander Alex Mercer',
    callSign: json['callSign'] as String? ?? 'ARES-1',
    role: json['role'] as String? ?? 'Mission Commander',
    roleArabic: json['roleArabic'] as String? ?? 'قائد البعثة الفضائية',
    robotName: json['robotName'] as String? ?? 'AEGIS-7',
    clearanceLevel: json['clearanceLevel'] as String? ?? 'NASA LEVEL-5 TOP SECRET',
  );
}

class CrewMember {
  final String id;
  final String name;
  final String nameAr;
  final String role;
  final String roleAr;
  final String callSign;
  final String location;
  final String frequency;

  const CrewMember({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.role,
    required this.roleAr,
    required this.callSign,
    required this.location,
    required this.frequency,
  });

  static const List<CrewMember> team = [
    CrewMember(
      id: 'dr_vance',
      name: 'Dr. Marcus Vance',
      nameAr: 'د. ماركوس فانس',
      role: 'Chief Planetary Geologist',
      roleAr: 'كبير الجيولوجيين الكوكبيين',
      callSign: 'GEO-LEAD',
      location: 'Surface Base Camp Hab',
      frequency: '433.92 MHz',
    ),
    CrewMember(
      id: 'lt_rostova',
      name: 'Lt. Elena Rostova',
      nameAr: 'ملازم إيلينا روستوفا',
      role: 'Avionics & Orbital Dynamics',
      roleAr: 'هندسة الملاحة والميكانيكا المدارية',
      callSign: 'AVIONICS-1',
      location: 'Orbital Recon Starship',
      frequency: '446.05 MHz',
    ),
    CrewMember(
      id: 'dr_tariq',
      name: 'Dr. Tariq Al-Hashimi',
      nameAr: 'د. طارق الهاشمي',
      role: 'Astrobiologist & Life Support',
      roleAr: 'أخصائي علم الأحياء الفلكية ودعم الحياة',
      callSign: 'BIO-SPEC',
      location: 'Gateway Clean Lab',
      frequency: '438.15 MHz',
    ),
    CrewMember(
      id: 'capcom',
      name: 'CAPCOM Houston / Gateway',
      nameAr: 'مركز التحكم الأرضي (كابكوم)',
      role: 'NASA Mission Director',
      roleAr: 'مدير العمليات الفضائية - ناسا',
      callSign: 'HOUSTON-DIR',
      location: 'Deep Space Network (DSN)',
      frequency: '2295.00 MHz',
    ),
  ];
}

class MissionTask {
  final String id;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final String requiredContactId;
  final String encryptedCode;
  final String transmissionData;
  final String transmissionDataAr;
  final bool isCompleted;
  final int xpReward;

  const MissionTask({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.requiredContactId,
    required this.encryptedCode,
    required this.transmissionData,
    required this.transmissionDataAr,
    this.isCompleted = false,
    this.xpReward = 50,
  });

  MissionTask copyWith({bool? isCompleted}) {
    return MissionTask(
      id: id,
      title: title,
      titleAr: titleAr,
      description: description,
      descriptionAr: descriptionAr,
      requiredContactId: requiredContactId,
      encryptedCode: encryptedCode,
      transmissionData: transmissionData,
      transmissionDataAr: transmissionDataAr,
      isCompleted: isCompleted ?? this.isCompleted,
      xpReward: xpReward,
    );
  }

  static List<MissionTask> getTasksFor(PlanetType planet, String siteName) {
    final lower = siteName.toLowerCase();

    if (planet == PlanetType.mars) {
      if (lower.contains('olympus')) {
        return [
          MissionTask(
            id: 'mars_olympus_1',
            title: 'Lava Tube Skylight Lidar Survey',
            titleAr: 'مسح فتحات كهوف الحمم بالليدار',
            description: 'Contact Lt. Elena Rostova to coordinate orbital radar pass and downlink 3D structural lidar mesh of the Olympus lava tube entrance.',
            descriptionAr: 'اتصل بالملازم إيلينا روستوفا لتنسيق المسح الراداري المداري واستلام شبكة الليدار ثلاثية الأبعاد لكهوف الحمم البركانية في بركان أوليمبوس.',
            requiredContactId: 'lt_rostova',
            encryptedCode: 'OLYMPUS-LIDAR-88',
            transmissionData: 'Orbital Recon locked! High-resolution lidar reveals a 45-meter wide lava tube cavern. Subsurface radiation levels drop 98% inside.',
            transmissionDataAr: 'تم تثبيت المسح المداري! الليدار يكشف عن كهف بركاني بعرض 45 متراً. الإشعاع ينخفض بنسبة 98% في الداخل، مما يجعله مثالياً لقاعدة مأهولة.',
            xpReward: 50,
          ),
          MissionTask(
            id: 'mars_olympus_2',
            title: 'Volcanic Basalt Mineralogy Calibration',
            titleAr: 'معايرة معادن البازلت البركاني',
            description: 'Radio Dr. Marcus Vance to verify X-ray fluorescence spectrometer standards for young tholeiitic basalt flows.',
            descriptionAr: 'تواصل مع د. ماركوس فانس لتأكيد معايير مطياف الأشعة السينية لصخور البازلت البركاني الحديثة في كالديرا أوليمبوس.',
            requiredContactId: 'dr_vance',
            encryptedCode: 'BASALT-THOL-33',
            transmissionData: 'Readings nominal, Commander! We are seeing high iron-titanium basalt with pristine glass margins. Extract a 5cm core sample.',
            transmissionDataAr: 'القراءات ممتازة أيها القائد! العينات تظهر بازلت غني بالحديد والتيتانيوم مع حواف زجاجية بركانية نقية. استخرج عينة بطول 5 سم.',
            xpReward: 50,
          ),
          MissionTask(
            id: 'mars_olympus_3',
            title: 'Low-Pressure Altitude Life Support Adjustment',
            titleAr: 'ضبط دعم الحياة لضغط الارتفاعات الشاهقة',
            description: 'Consult Dr. Tariq Al-Hashimi to adapt suit pressure regulators for 21.9 km altitude near-vacuum conditions.',
            descriptionAr: 'استشر د. طارق الهاشمي لضبط منظمات ضغط البذلة لظروف شبه الفراغ على ارتفاع 21.9 كم فوق قمة أوليمبوس.',
            requiredContactId: 'dr_tariq',
            encryptedCode: 'ALT-PRESS-60PA',
            transmissionData: 'Suit telemetry synced. Outside atmospheric pressure is only 60 Pascals. Maintain internal suit pressure at 30 kPa pure O2.',
            transmissionDataAr: 'تمت مزامنة البذلة. الضغط الجوي الخارجي يبلغ 60 باسكال فقط. حافظ على ضغط البذلة الداخلي عند 30 كيلوباسكال من الأكسجين النقي.',
            xpReward: 50,
          ),
        ];
      } else if (lower.contains('valles') || lower.contains('marineris')) {
        return [
          MissionTask(
            id: 'mars_valles_1',
            title: 'Tectonic Rift Strata Sounding',
            titleAr: 'المسح الراداري للصدوع التكتونية العميقة',
            description: 'Contact Dr. Marcus Vance to acquire subsurface fault imaging across the 7-km deep Valles Marineris canyon cliffs.',
            descriptionAr: 'اتصل بـ د. ماركوس فانس للحصول على تصوير الصدوع التكتونية عبر جدران وادي مارينر العظيم البالغ عمقها 7 كيلومترات.',
            requiredContactId: 'dr_vance',
            encryptedCode: 'RIFT-FAULT-7000',
            transmissionData: 'Canyon wall telemetry received. Layered basaltic lava flows alternate with sedimentary megabreccia. Target hydrated sulfate deposits.',
            transmissionDataAr: 'تم استلام بيانات جدار الأخدود. طبقات الحمم البركانية تتناوب مع صخور الرواسب. استهدف رواسب الكبريتات المائية.',
            xpReward: 50,
          ),
          MissionTask(
            id: 'mars_valles_2',
            title: 'Canyon Wind Velocity Navigation',
            titleAr: 'ملاحة سرعة الرياح الأخدودية العاتية',
            description: 'Request wind shear advisory from Lt. Elena Rostova for safe traversal of the chasma floor.',
            descriptionAr: 'اطلب إرشادات قص الرياح من الملازم إيلينا روستوفا لعبور آمن لأرضية الأخدود العملاق.',
            requiredContactId: 'lt_rostova',
            encryptedCode: 'WIND-SHEAR-CHASMA',
            transmissionData: 'Warning: Katabatic winds peaking at 42 km/h flowing down the northern wall. Maintain anchor boots and deploy inertial stabilizers.',
            transmissionDataAr: 'تحذير: رياح هابطة بسرعة 42 كم/ساعة تتدفق من الجدار الشمالي. فعّل مثبتات الأحذية الجيروسكوبية وحافظ على الاتزان.',
            xpReward: 50,
          ),
        ];
      } else if (lower.contains('gale')) {
        return [
          MissionTask(
            id: 'mars_gale_1',
            title: 'Mount Sharp Layered Sediment Extraction',
            titleAr: 'استخراج رواسب جبل شارب الطبقية',
            description: 'Contact Dr. Marcus Vance to analyze clay-bearing mudstones reflecting ancient Martian lakes in Gale Crater.',
            descriptionAr: 'تواصل مع د. ماركوس فانس لتحليل الصخور الطينية الرسوبية التي تعكس بيئة بحيرات المريخ القديمة في فوهة غيل.',
            requiredContactId: 'dr_vance',
            encryptedCode: 'GALE-SHARP-CLAY',
            transmissionData: 'Spectrometer reports high smectite clay signatures. This confirms a benign, habitable freshwater environment billions of years ago.',
            transmissionDataAr: 'المطياف يؤكد وجود معادن الطين السميكتيتية. هذا دليل قاطع على بيئة مياه عذبة صالحة للحياة قبل مليارات السنين.',
            xpReward: 50,
          ),
          MissionTask(
            id: 'mars_gale_2',
            title: 'Methane Plume Detection Protocol',
            titleAr: 'بروتوكول تتبع انبعاثات الميثان الغازي',
            description: 'Check in with Dr. Tariq Al-Hashimi to calibrate tunable laser spectrometer for periodic methane seepage.',
            descriptionAr: 'اتصل بـ د. طارق الهاشمي لمعايرة مطياف الليزر القابل للتوليف لرصد تسربات غاز الميثان الموضعية.',
            requiredContactId: 'dr_tariq',
            encryptedCode: 'CH4-TLS-PEAK',
            transmissionData: 'Background CH4 levels fluctuating at 12 parts per billion. Seal atmospheric gas canister immediately for laboratory isotope analysis.',
            transmissionDataAr: 'نسبة الميثان تتذبذب عند 12 جزءاً في المليار. أغلق أسطوانة الغاز الجوي فوراً لتحليل النظائر المعملي.',
            xpReward: 50,
          ),
        ];
      } else {
        // Jezero Crater (Default Mars)
        return [
          MissionTask(
            id: 'mars_jezero_1',
            title: 'Delta Biosignature Sampling Protocol',
            titleAr: 'بروتوكول جمع عينات البصمات الحيوية من الدلتا',
            description: 'Establish secure quantum radio comms with Dr. Marcus Vance to receive the encrypted sensor frequency for Jezero river delta bedrock.',
            descriptionAr: 'أنشئ اتصالاً لاسلكياً مشفراً مع د. ماركوس فانس لاستلام تردد المعايرة المشفر لحفر صخور دلتا نهر جيزيرو القديمة.',
            requiredContactId: 'dr_vance',
            encryptedCode: 'JEZERO-RAMAN-532',
            transmissionData: 'Commander! Decryption successful. Core drill laser tuned to 532 nm Raman frequency. Target the fine-grained silica-carbonate interface.',
            transmissionDataAr: 'أيها القائد! تم فك التشفير بنجاح. تم ضبط ليزر الحفر على تردد رامان 532 نانومتر. استهدف واجهة الصخور الكربوناتية والسيليكا الدقيقة.',
            xpReward: 50,
          ),
          MissionTask(
            id: 'mars_jezero_2',
            title: 'Perseverance Cache Recovery Vector',
            titleAr: 'تأكيد إحداثيات أنابيب عينات بيرسيفيرانس',
            description: 'Contact Lt. Elena Rostova to acquire terminal descent vector and coordinate tag for historic sample tube depot.',
            descriptionAr: 'اتصل بالملازم إيلينا روستوفا للحصول على إحداثيات مستودع أنابيب العينات التاريخية التي أودعتها بيرسيفيرانس.',
            requiredContactId: 'lt_rostova',
            encryptedCode: 'CACHE-DEPOT-04',
            transmissionData: 'Trajectory verified, Commander. Cache depot coordinates locked. Retain sealed titanium tubes for Mars Sample Return ascent vehicle.',
            transmissionDataAr: 'تم تأكيد المسار أيها القائد. إحداثيات مستودع العينات مثبتة. جهّز أسطوانات التيتانيوم لنقلها لمركبة الإقلاع نحو الأرض.',
            xpReward: 50,
          ),
          MissionTask(
            id: 'mars_jezero_3',
            title: 'Organic Carbon Spectrometry Sync',
            titleAr: 'مزامنة قياسات الكربون العضوي',
            description: 'Check in with Dr. Tariq Al-Hashimi to calibrate astrobiology sensors and confirm polycyclic aromatic hydrocarbon bounds.',
            descriptionAr: 'تواصل مع د. طارق الهاشمي لمعايرة مستشعرات علم الأحياء الفلكية وتأكيد بصمات المركبات العضوية العطرية.',
            requiredContactId: 'dr_tariq',
            encryptedCode: 'BIO-CARBON-PAH',
            transmissionData: 'Fluorescence signals detected in rock core! Carbon ring structures verified. Keep sample container at -60°C vacuum seal.',
            transmissionDataAr: 'تم رصد إشارات فلورية في الصخر! حلقات الكربون العضوي مؤكدة. احفظ الحاوية في فراغ مبرد عند -60 درجة مئوية.',
            xpReward: 50,
          ),
        ];
      }
    } else {
      // Moon Missions
      if (lower.contains('shackleton') || lower.contains('south pole') || lower.contains('قطب')) {
        return [
          MissionTask(
            id: 'moon_shackleton_1',
            title: 'Cryogenic Water-Ice Drill Calibration',
            titleAr: 'معايرة حفار جليد الماء فائق التبريد',
            description: 'Establish comms with Dr. Tariq Al-Hashimi to unlock the permanently shadowed crater cryogenic core sampling sequence at Shackleton Crater.',
            descriptionAr: 'أنشئ اتصالاً مع د. طارق الهاشمي لفتح تسلسل حفر الجليد فائق التبريد في الفوهات المظللة دائماً في فوهة شاكلتون.',
            requiredContactId: 'dr_tariq',
            encryptedCode: 'CRYO-LCROSS-88',
            transmissionData: 'Authorization granted! LCROSS neutron spectrometer confirms 5.5 wt% pure water ice. Maintain drill temperature strictly below 40 Kelvin.',
            transmissionDataAr: 'تم منح التصريح! مطياف النيوترونات يؤكد وجود جليد مائي نقي بنسبة 5.5%. حافظ على درجة حرارة الحفار دون 40 كلفن لتفادي تسامي الجليد.',
            xpReward: 50,
          ),
          MissionTask(
            id: 'moon_shackleton_2',
            title: 'Perpetual Light Rim Solar Power Link',
            titleAr: 'ربط مصفوفة الطاقة الشمسية المستمرة',
            description: 'Contact Lt. Elena Rostova to align microwave power beam from Shackleton rim solar towers to the shadowed crater floor.',
            descriptionAr: 'اتصل بالملازم إيلينا روستوفا لمحاذاة شعاع الميكروويف اللاسلكي من أبراج الطاقة الشمسية على حافة شاكلتون إلى قاع الفوهة المظلم.',
            requiredContactId: 'lt_rostova',
            encryptedCode: 'SOLAR-BEAM-99.4',
            transmissionData: 'Power link locked! Receiving 18 kW continuous microwave power from the rim tower. Suit battery recharging active.',
            transmissionDataAr: 'تم قفل خط نقل الطاقة! نستلم 18 كيلوواط من الطاقة المستمرة عبر برج الحافة المضاء دائماً. بطارية البذلة تشحن الآن بنجاح.',
            xpReward: 50,
          ),
        ];
      } else if (lower.contains('tranquillity') || lower.contains('apollo') || lower.contains('هدوء')) {
        return [
          MissionTask(
            id: 'moon_tranquillity_1',
            title: 'Apollo 11 Artifact Laser Ranging Alignment',
            titleAr: 'محاذاة عاكس الليزر القمري لأبولو 11',
            description: 'Contact Houston / CAPCOM to align observatory ground lasers with the 1969 Apollo 11 Retroreflector Array.',
            descriptionAr: 'اتصل بمركز كابكوم لمزامنة ليزر المراصد الأرضية مع مصفوفة العواكس الليزرية التاريخية لمهمة أبولو 11 في بحر الهدوء.',
            requiredContactId: 'capcom',
            encryptedCode: 'APOLLO-LRRR-1969',
            transmissionData: 'Green laser pulse detected from McDonald Observatory! Earth-Moon distance measured at 384,402,114.2 millimeters with 1mm precision.',
            transmissionDataAr: 'تم رصد نبضة الليزر الخضراء من مرصد ماكدونالد! تم قياس المسافة بين الأرض والقمر بدقة 1 ملم: 384,402,114.2 مليمتر.',
            xpReward: 50,
          ),
          MissionTask(
            id: 'moon_tranquillity_2',
            title: 'High-Titanium Ilmenite ISRU Decryption',
            titleAr: 'مفتاح تحليل خامات التيتانيوم وإنتاج الأكسجين',
            description: 'Contact Dr. Marcus Vance to retrieve high-titanium regolith melting protocols for Artemis oxygen generation.',
            descriptionAr: 'اتصل بـ د. ماركوس فانس لاستلام بروتوكول صهر الثرى الغني بالتيتانيوم لإنتاج الأكسجين المستدام لقواعد أرتميس.',
            requiredContactId: 'dr_vance',
            encryptedCode: 'ISRU-TI-O2-901',
            transmissionData: 'Transmission confirmed! High-titanium ilmenite detected in Mare basalt. Electrolysis yield estimated at 14% pure O2 volume.',
            transmissionDataAr: 'تم تأكيد الإرسال! خامات التيتانيوم في بحر الهدوء تتيح استخلاص الأكسجين بنسبة 14% عبر صهر الثرى بالتحليل الكهربائي.',
            xpReward: 50,
          ),
        ];
      } else if (lower.contains('copernicus') || lower.contains('كوبرنيكوس')) {
        return [
          MissionTask(
            id: 'moon_copernicus_1',
            title: 'Central Peak Uplift Petrology',
            titleAr: 'تحليل صخور القمة المركزية المرفوعة',
            description: 'Contact Dr. Marcus Vance to analyze deep crustal rocks excavated from 30 km depth by the Copernicus impact.',
            descriptionAr: 'تواصل مع د. ماركوس فانس لفحص صخور القشرة العميقة التي قذفها اصطدام كوبرنيكوس من عمق 30 كم لتشكيل القمة المركزية.',
            requiredContactId: 'dr_vance',
            encryptedCode: 'COPERNICUS-PEAK-30KM',
            transmissionData: 'Spectrometry shows pure troctolite and olivine-rich rocks from the deep lunar crust! Collect core samples from the central spire.',
            transmissionDataAr: 'المطياف يؤكد وجود صخور التروكتوليت والأوليفين النقية من قشرة القمر العميقة! اجمع عينات أساسية من البرج المركزي.',
            xpReward: 50,
          ),
          MissionTask(
            id: 'moon_copernicus_2',
            title: 'Impact Melt Sheet Chronology',
            titleAr: 'تأريخ صفائح صهارة الاصطدام',
            description: 'Consult Lt. Elena Rostova to correlate impact melt crystallization age with the lunar cratering chronology.',
            descriptionAr: 'استشر الملازم إيلينا روستوفا لمطابقة عمر تبلور صهارة الارتطام مع الخط الزمني لفوهات المجموعة الشمسية.',
            requiredContactId: 'lt_rostova',
            encryptedCode: 'MELT-SHEET-800MA',
            transmissionData: 'Argon-argon isotope calibration confirms age at ~800 million years. This serves as key calibration for solar system impact history.',
            transmissionDataAr: 'معايرة نظائر الأرجون تؤكد أن عمر الاصطدام يبلغ 800 مليون سنة، مما يشكل حجر الزاوية لتأريخ فوهات النظام الشمسي بأكمله.',
            xpReward: 50,
          ),
        ];
      } else {
        // South Pole-Aitken / Malapert Mountain
        return [
          MissionTask(
            id: 'moon_aitken_1',
            title: 'Deep Lunar Mantle Core Sampling',
            titleAr: 'حفر عينات وشاح القمر العميق',
            description: 'Contact Dr. Marcus Vance to verify mantle mineral spectra excavated by the gargantuan South Pole-Aitken impact.',
            descriptionAr: 'تواصل مع د. ماركوس فانس لتأكيد معادن وشاح القمر المعراة نتيجة الاصطدام العملاق لحوض أيتكين.',
            requiredContactId: 'dr_vance',
            encryptedCode: 'MANTLE-SPA-CORE',
            transmissionData: 'Pyroxene and low-calcium orthopyroxene detected! This is the first confirmed sample of the Moon inner mantle ever retrieved.',
            transmissionDataAr: 'تم رصد البيروكسين منخفض الكالسيوم! هذه أول عينة مؤكدة من وشاح القمر الداخلي يتم الوصول إليها في التاريخ.',
            xpReward: 50,
          ),
          MissionTask(
            id: 'moon_aitken_2',
            title: 'Far-Side Radio Astronomy Relay Activation',
            titleAr: 'تفعيل محطة اتصالات تلسكوب الجانب البعيد',
            description: 'Contact Houston / Lunar Gateway to commission low-frequency radio relay shielded from Earth radio frequency interference.',
            descriptionAr: 'اتصل بمركز كابكوم لتدشين محطة التتابع الراديوي على الجانب البعيد من القمر، المعزول تماماً عن التشويش الراديوي للأرض.',
            requiredContactId: 'capcom',
            encryptedCode: 'RADIO-DARK-QUIET',
            transmissionData: 'Far-side array active! Radio noise floor is at theoretical minimum. First cosmological 21-cm Dark Ages signal locked.',
            transmissionDataAr: 'المصفوفة الراديوية تعمل بنجاح! تم رصد أول إشارة كوزمولوجية نقية بطول موجي 21 سم تعود للحقبة المظلمة للكون.',
            xpReward: 50,
          ),
        ];
      }
    }
  }

}
