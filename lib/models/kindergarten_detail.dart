class KindergartenDetail {
  final String id;
  final String name;
  final String establishType;
  final String address;
  final String phone;
  final String? homepage;
  final String? operatingHours;
  final double lat;
  final double lng;
  final String? representativeName;
  final String? directorName;
  final DateTime? establishDate;
  final DateTime? openDate;
  final EducationSection education;
  final MealSection meal;
  final SafetySection safety;
  final FacilitySection facility;
  final TeacherSection teacher;
  final AfterSchoolSection afterSchool;
  final DateTime sourceUpdatedAt;

  const KindergartenDetail({
    required this.id,
    required this.name,
    required this.establishType,
    required this.address,
    required this.phone,
    this.homepage,
    this.operatingHours,
    required this.lat,
    required this.lng,
    this.representativeName,
    this.directorName,
    this.establishDate,
    this.openDate,
    required this.education,
    required this.meal,
    required this.safety,
    required this.facility,
    required this.teacher,
    required this.afterSchool,
    required this.sourceUpdatedAt,
  });

  factory KindergartenDetail.fromJson(Map<String, dynamic> json) {
    return KindergartenDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      establishType: json['establishType'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      homepage: json['homepage'],
      operatingHours: json['operatingHours'],
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      representativeName: json['representativeName'],
      directorName: json['directorName'],
      establishDate: json['establishDate'] != null
          ? _parseDate(json['establishDate'])
          : null,
      openDate: json['openDate'] != null
          ? _parseDate(json['openDate'])
          : null,
      education: EducationSection.fromJson(json['education'] ?? {}),
      meal: MealSection.fromJson(json['meal'] ?? {}),
      safety: SafetySection.fromJson(json['safety'] ?? {}),
      facility: FacilitySection.fromJson(json['facility'] ?? {}),
      teacher: TeacherSection.fromJson(json['teacher'] ?? {}),
      afterSchool: AfterSchoolSection.fromJson(json['afterSchool'] ?? {}),
      sourceUpdatedAt: DateTime.tryParse(json['sourceUpdatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    
    // "20220301" 형태인 경우
    if (dateStr.length == 8 && RegExp(r'^\d{8}$').hasMatch(dateStr)) {
      final year = int.tryParse(dateStr.substring(0, 4));
      final month = int.tryParse(dateStr.substring(4, 6));
      final day = int.tryParse(dateStr.substring(6, 8));
      
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }
    
    // ISO 형태인 경우
    return DateTime.tryParse(dateStr);
  }
}

class EducationSection {
  final ClassCountByAge classCountByAge;
  final CapacityByAge capacityByAge;
  final EnrollmentByAge enrollmentByAge;
  final int lessonDaysAge3;
  final int lessonDaysAge4;
  final int lessonDaysAge5;
  final int? lessonDaysMixed;
  final String belowLegalDays;

  const EducationSection({
    required this.classCountByAge,
    required this.capacityByAge,
    required this.enrollmentByAge,
    required this.lessonDaysAge3,
    required this.lessonDaysAge4,
    required this.lessonDaysAge5,
    this.lessonDaysMixed,
    required this.belowLegalDays,
  });

  factory EducationSection.fromJson(Map<String, dynamic> json) {
    return EducationSection(
      classCountByAge: ClassCountByAge.fromJson(json['classCountByAge'] ?? {}),
      capacityByAge: CapacityByAge.fromJson(json['capacityByAge'] ?? {}),
      enrollmentByAge: EnrollmentByAge.fromJson(json['enrollmentByAge'] ?? {}),
      lessonDaysAge3: json['lessonDaysAge3'] ?? 0,
      lessonDaysAge4: json['lessonDaysAge4'] ?? 0,
      lessonDaysAge5: json['lessonDaysAge5'] ?? 0,
      lessonDaysMixed: json['lessonDaysMixed'],
      belowLegalDays: json['belowLegalDays'] ?? 'N',
    );
  }
}

class ClassCountByAge {
  final int age3;
  final int age4;
  final int age5;
  final int mixed;
  final int special;

  const ClassCountByAge({
    required this.age3,
    required this.age4,
    required this.age5,
    required this.mixed,
    required this.special,
  });

  factory ClassCountByAge.fromJson(Map<String, dynamic> json) {
    return ClassCountByAge(
      age3: json['age3'] ?? 0,
      age4: json['age4'] ?? 0,
      age5: json['age5'] ?? 0,
      mixed: json['mixed'] ?? 0,
      special: json['special'] ?? 0,
    );
  }

  int get total => age3 + age4 + age5 + mixed + special;
}

class CapacityByAge {
  final int age3;
  final int age4;
  final int age5;
  final int mixed;
  final int special;

  const CapacityByAge({
    required this.age3,
    required this.age4,
    required this.age5,
    required this.mixed,
    required this.special,
  });

  factory CapacityByAge.fromJson(Map<String, dynamic> json) {
    return CapacityByAge(
      age3: json['age3'] ?? 0,
      age4: json['age4'] ?? 0,
      age5: json['age5'] ?? 0,
      mixed: json['mixed'] ?? 0,
      special: json['special'] ?? 0,
    );
  }

  int get total => age3 + age4 + age5 + mixed + special;
}

class EnrollmentByAge {
  final int age3;
  final int age4;
  final int age5;
  final int mixed;
  final int special;

  const EnrollmentByAge({
    required this.age3,
    required this.age4,
    required this.age5,
    required this.mixed,
    required this.special,
  });

  factory EnrollmentByAge.fromJson(Map<String, dynamic> json) {
    return EnrollmentByAge(
      age3: json['age3'] ?? 0,
      age4: json['age4'] ?? 0,
      age5: json['age5'] ?? 0,
      mixed: json['mixed'] ?? 0,
      special: json['special'] ?? 0,
    );
  }

  int get total => age3 + age4 + age5 + mixed + special;
}

class MealSection {
  final String mealOperationType;
  final String? consignmentCompany;
  final int mealChildren;
  final int cookCount;

  const MealSection({
    required this.mealOperationType,
    this.consignmentCompany,
    required this.mealChildren,
    required this.cookCount,
  });

  factory MealSection.fromJson(Map<String, dynamic> json) {
    return MealSection(
      mealOperationType: json['mealOperationType'] ?? '',
      consignmentCompany: json['consignmentCompany'],
      mealChildren: json['mealChildren'] ?? 0,
      cookCount: json['cookCount'] ?? 0,
    );
  }
}

class SafetySection {
  final String airQualityCheck;
  final String disinfectionCheck;
  final String waterQualityCheck;
  final String dustMeasurement;
  final String lightMeasurement;
  final String fireInsuranceCheck;
  final String gasCheck;
  final String electricCheck;
  final String playgroundCheck;
  final String cctvInstalled;
  final int cctvTotal;
  final String schoolSafetyEnrolled;
  final String educationFacilityEnrolled;

  const SafetySection({
    required this.airQualityCheck,
    required this.disinfectionCheck,
    required this.waterQualityCheck,
    required this.dustMeasurement,
    required this.lightMeasurement,
    required this.fireInsuranceCheck,
    required this.gasCheck,
    required this.electricCheck,
    required this.playgroundCheck,
    required this.cctvInstalled,
    required this.cctvTotal,
    required this.schoolSafetyEnrolled,
    required this.educationFacilityEnrolled,
  });

  factory SafetySection.fromJson(Map<String, dynamic> json) {
    return SafetySection(
      airQualityCheck: json['airQualityCheck'] ?? '',
      disinfectionCheck: json['disinfectionCheck'] ?? '',
      waterQualityCheck: json['waterQualityCheck'] ?? '',
      dustMeasurement: json['dustMeasurement'] ?? '',
      lightMeasurement: json['lightMeasurement'] ?? '',
      fireInsuranceCheck: json['fireInsuranceCheck'] ?? '',
      gasCheck: json['gasCheck'] ?? '',
      electricCheck: json['electricCheck'] ?? '',
      playgroundCheck: json['playgroundCheck'] ?? '',
      cctvInstalled: json['cctvInstalled'] ?? '',
      cctvTotal: json['cctvTotal'] ?? 0,
      schoolSafetyEnrolled: json['schoolSafetyEnrolled'] ?? '',
      educationFacilityEnrolled: json['educationFacilityEnrolled'] ?? '',
    );
  }
}

class FacilitySection {
  final int archYear;
  final int floorCount;
  final double buildingArea;
  final double totalLandArea;
  final int classroomCount;
  final double classroomArea;
  final double playgroundArea;
  final String busOperating;
  final int operatingBusCount;
  final int registeredBusCount;

  const FacilitySection({
    required this.archYear,
    required this.floorCount,
    required this.buildingArea,
    required this.totalLandArea,
    required this.classroomCount,
    required this.classroomArea,
    required this.playgroundArea,
    required this.busOperating,
    required this.operatingBusCount,
    required this.registeredBusCount,
  });

  factory FacilitySection.fromJson(Map<String, dynamic> json) {
    return FacilitySection(
      archYear: json['archYear'] ?? 0,
      floorCount: json['floorCount'] ?? 0,
      buildingArea: (json['buildingArea'] ?? 0.0).toDouble(),
      totalLandArea: (json['totalLandArea'] ?? 0.0).toDouble(),
      classroomCount: json['classroomCount'] ?? 0,
      classroomArea: (json['classroomArea'] ?? 0.0).toDouble(),
      playgroundArea: (json['playgroundArea'] ?? 0.0).toDouble(),
      busOperating: json['busOperating'] ?? 'N',
      operatingBusCount: json['operatingBusCount'] ?? 0,
      registeredBusCount: json['registeredBusCount'] ?? 0,
    );
  }
}

class TeacherSection {
  final int directorCount;
  final int viceDirectorCount;
  final int masterTeacherCount;
  final int leadTeacherCount;
  final int generalTeacherCount;
  final int specialTeacherCount;
  final int healthTeacherCount;
  final int nutritionTeacherCount;
  final int staffCount;
  final int masterQualCount;
  final int grade1QualCount;
  final int grade2QualCount;
  final int assistantQualCount;
  final int under1Year;
  final int between1And2Years;
  final int between2And4Years;
  final int between4And6Years;
  final int over6Years;

  const TeacherSection({
    required this.directorCount,
    required this.viceDirectorCount,
    required this.masterTeacherCount,
    required this.leadTeacherCount,
    required this.generalTeacherCount,
    required this.specialTeacherCount,
    required this.healthTeacherCount,
    required this.nutritionTeacherCount,
    required this.staffCount,
    required this.masterQualCount,
    required this.grade1QualCount,
    required this.grade2QualCount,
    required this.assistantQualCount,
    required this.under1Year,
    required this.between1And2Years,
    required this.between2And4Years,
    required this.between4And6Years,
    required this.over6Years,
  });

  factory TeacherSection.fromJson(Map<String, dynamic> json) {
    return TeacherSection(
      directorCount: json['directorCount'] ?? 0,
      viceDirectorCount: json['viceDirectorCount'] ?? 0,
      masterTeacherCount: json['masterTeacherCount'] ?? 0,
      leadTeacherCount: json['leadTeacherCount'] ?? 0,
      generalTeacherCount: json['generalTeacherCount'] ?? 0,
      specialTeacherCount: json['specialTeacherCount'] ?? 0,
      healthTeacherCount: json['healthTeacherCount'] ?? 0,
      nutritionTeacherCount: json['nutritionTeacherCount'] ?? 0,
      staffCount: json['staffCount'] ?? 0,
      masterQualCount: json['masterQualCount'] ?? 0,
      grade1QualCount: json['grade1QualCount'] ?? 0,
      grade2QualCount: json['grade2QualCount'] ?? 0,
      assistantQualCount: json['assistantQualCount'] ?? 0,
      under1Year: json['under1Year'] ?? 0,
      between1And2Years: json['between1And2Years'] ?? 0,
      between2And4Years: json['between2And4Years'] ?? 0,
      between4And6Years: json['between4And6Years'] ?? 0,
      over6Years: json['over6Years'] ?? 0,
    );
  }

  int get totalTeacherCount {
    return directorCount + viceDirectorCount + masterTeacherCount +
           leadTeacherCount + generalTeacherCount + specialTeacherCount +
           healthTeacherCount + nutritionTeacherCount;
  }
}

class AfterSchoolSection {
  final int independentClassCount;
  final int afternoonClassCount;
  final int independentParticipants;
  final int afternoonParticipants;
  final int regularTeacherCount;
  final int contractTeacherCount;
  final int dedicatedStaffCount;

  const AfterSchoolSection({
    required this.independentClassCount,
    required this.afternoonClassCount,
    required this.independentParticipants,
    required this.afternoonParticipants,
    required this.regularTeacherCount,
    required this.contractTeacherCount,
    required this.dedicatedStaffCount,
  });

  factory AfterSchoolSection.fromJson(Map<String, dynamic> json) {
    return AfterSchoolSection(
      independentClassCount: json['independentClassCount'] ?? 0,
      afternoonClassCount: json['afternoonClassCount'] ?? 0,
      independentParticipants: json['independentParticipants'] ?? 0,
      afternoonParticipants: json['afternoonParticipants'] ?? 0,
      regularTeacherCount: json['regularTeacherCount'] ?? 0,
      contractTeacherCount: json['contractTeacherCount'] ?? 0,
      dedicatedStaffCount: json['dedicatedStaffCount'] ?? 0,
    );
  }
}