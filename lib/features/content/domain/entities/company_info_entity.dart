import 'package:equatable/equatable.dart';

class BranchOfficeEntity extends Equatable {
  final String name;
  final String address;

  const BranchOfficeEntity({required this.name, required this.address});

  @override
  List<Object?> get props => [name, address];
}

class CompanyInfoEntity extends Equatable {
  final String heroBadge;
  final String heroHeadline;
  final String aboutShort;
  final String missionText;
  final String visionText;
  final String regOfficeAddress;
  final List<String> contactNumbers;
  final String email;
  final String website;
  final String gstn;
  final String vendorCode;
  final String businessHours;
  final int experienceYears;
  final int statesServed;
  final double capacityInstalledMw;
  final String ceoName;
  final String ceoQuote;
  final String ceoBio;
  final int teamExperienceYears;
  final int teamProjectsCompleted;
  final int teamMembers;
  final int teamSatisfactionPercent;
  final List<BranchOfficeEntity> branchOffices;

  const CompanyInfoEntity({
    required this.heroBadge,
    required this.heroHeadline,
    required this.aboutShort,
    required this.missionText,
    required this.visionText,
    required this.regOfficeAddress,
    required this.contactNumbers,
    required this.email,
    required this.website,
    required this.gstn,
    required this.vendorCode,
    required this.businessHours,
    required this.experienceYears,
    required this.statesServed,
    required this.capacityInstalledMw,
    required this.ceoName,
    required this.ceoQuote,
    required this.ceoBio,
    required this.teamExperienceYears,
    required this.teamProjectsCompleted,
    required this.teamMembers,
    required this.teamSatisfactionPercent,
    required this.branchOffices,
  });

  @override
  List<Object?> get props => [
        heroBadge,
        heroHeadline,
        aboutShort,
        missionText,
        visionText,
        regOfficeAddress,
        contactNumbers,
        email,
        website,
        gstn,
        vendorCode,
        businessHours,
        experienceYears,
        statesServed,
        capacityInstalledMw,
        ceoName,
        ceoQuote,
        ceoBio,
        teamExperienceYears,
        teamProjectsCompleted,
        teamMembers,
        teamSatisfactionPercent,
        branchOffices,
      ];
}
