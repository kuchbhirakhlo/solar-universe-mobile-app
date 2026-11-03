import 'package:equatable/equatable.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/company_info_entity.dart';
import '../../domain/entities/faq_entity.dart';
import '../../domain/entities/package_entity.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/solution_entity.dart';

enum LoadStatus { initial, loading, success, failure }

class ContentState extends Equatable {
  final LoadStatus companyStatus;
  final CompanyInfoEntity? companyInfo;
  final String? companyError;

  final LoadStatus packagesStatus;
  final List<PackageEntity> packages;
  final String? packagesError;

  final LoadStatus solutionsStatus;
  final List<SolutionEntity> solutions;
  final String? solutionsError;

  final LoadStatus projectsStatus;
  final List<ProjectEntity> projects;
  final String? projectsError;

  final LoadStatus faqsStatus;
  final List<FaqEntity> faqs;
  final String? faqsError;

  final LoadStatus brandsStatus;
  final List<BrandEntity> brands;
  final String? brandsError;

  const ContentState({
    this.companyStatus = LoadStatus.initial,
    this.companyInfo,
    this.companyError,
    this.packagesStatus = LoadStatus.initial,
    this.packages = const [],
    this.packagesError,
    this.solutionsStatus = LoadStatus.initial,
    this.solutions = const [],
    this.solutionsError,
    this.projectsStatus = LoadStatus.initial,
    this.projects = const [],
    this.projectsError,
    this.faqsStatus = LoadStatus.initial,
    this.faqs = const [],
    this.faqsError,
    this.brandsStatus = LoadStatus.initial,
    this.brands = const [],
    this.brandsError,
  });

  ContentState copyWith({
    LoadStatus? companyStatus,
    CompanyInfoEntity? companyInfo,
    String? companyError,
    LoadStatus? packagesStatus,
    List<PackageEntity>? packages,
    String? packagesError,
    LoadStatus? solutionsStatus,
    List<SolutionEntity>? solutions,
    String? solutionsError,
    LoadStatus? projectsStatus,
    List<ProjectEntity>? projects,
    String? projectsError,
    LoadStatus? faqsStatus,
    List<FaqEntity>? faqs,
    String? faqsError,
    LoadStatus? brandsStatus,
    List<BrandEntity>? brands,
    String? brandsError,
  }) {
    return ContentState(
      companyStatus: companyStatus ?? this.companyStatus,
      companyInfo: companyInfo ?? this.companyInfo,
      companyError: companyError,
      packagesStatus: packagesStatus ?? this.packagesStatus,
      packages: packages ?? this.packages,
      packagesError: packagesError,
      solutionsStatus: solutionsStatus ?? this.solutionsStatus,
      solutions: solutions ?? this.solutions,
      solutionsError: solutionsError,
      projectsStatus: projectsStatus ?? this.projectsStatus,
      projects: projects ?? this.projects,
      projectsError: projectsError,
      faqsStatus: faqsStatus ?? this.faqsStatus,
      faqs: faqs ?? this.faqs,
      faqsError: faqsError,
      brandsStatus: brandsStatus ?? this.brandsStatus,
      brands: brands ?? this.brands,
      brandsError: brandsError,
    );
  }

  @override
  List<Object?> get props => [
        companyStatus,
        companyInfo,
        companyError,
        packagesStatus,
        packages,
        packagesError,
        solutionsStatus,
        solutions,
        solutionsError,
        projectsStatus,
        projects,
        projectsError,
        faqsStatus,
        faqs,
        faqsError,
        brandsStatus,
        brands,
        brandsError,
      ];
}
