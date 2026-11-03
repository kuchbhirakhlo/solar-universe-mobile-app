import '../../domain/entities/company_info_entity.dart';

class CompanyInfoModel extends CompanyInfoEntity {
  const CompanyInfoModel({
    required super.heroBadge,
    required super.heroHeadline,
    required super.aboutShort,
    required super.missionText,
    required super.visionText,
    required super.regOfficeAddress,
    required super.contactNumbers,
    required super.email,
    required super.website,
    required super.gstn,
    required super.vendorCode,
    required super.businessHours,
    required super.experienceYears,
    required super.statesServed,
    required super.capacityInstalledMw,
    required super.ceoName,
    required super.ceoQuote,
    required super.ceoBio,
    required super.teamExperienceYears,
    required super.teamProjectsCompleted,
    required super.teamMembers,
    required super.teamSatisfactionPercent,
    required super.branchOffices,
  });

  factory CompanyInfoModel.fromMap(Map<String, dynamic> map) {
    return CompanyInfoModel(
      heroBadge: map['heroBadge'] as String? ?? '',
      heroHeadline: map['heroHeadline'] as String? ?? '',
      aboutShort: map['aboutShort'] as String? ?? '',
      missionText: map['missionText'] as String? ?? '',
      visionText: map['visionText'] as String? ?? '',
      regOfficeAddress: map['regOfficeAddress'] as String? ?? '',
      contactNumbers: List<String>.from(map['contactNumbers'] as List? ?? const []),
      email: map['email'] as String? ?? '',
      website: map['website'] as String? ?? '',
      gstn: map['gstn'] as String? ?? '',
      vendorCode: map['vendorCode'] as String? ?? '',
      businessHours: map['businessHours'] as String? ?? '',
      experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 0,
      statesServed: (map['statesServed'] as num?)?.toInt() ?? 0,
      capacityInstalledMw: (map['capacityInstalledMw'] as num?)?.toDouble() ?? 0,
      ceoName: map['ceoName'] as String? ?? '',
      ceoQuote: map['ceoQuote'] as String? ?? '',
      ceoBio: map['ceoBio'] as String? ?? '',
      teamExperienceYears: (map['teamExperienceYears'] as num?)?.toInt() ?? 0,
      teamProjectsCompleted: (map['teamProjectsCompleted'] as num?)?.toInt() ?? 0,
      teamMembers: (map['teamMembers'] as num?)?.toInt() ?? 0,
      teamSatisfactionPercent: (map['teamSatisfactionPercent'] as num?)?.toInt() ?? 100,
      branchOffices: ((map['branchOffices'] as List?) ?? const [])
          .map((e) => BranchOfficeEntity(
                name: (e as Map)['name'] as String? ?? '',
                address: e['address'] as String? ?? '',
              ))
          .toList(),
    );
  }
}
