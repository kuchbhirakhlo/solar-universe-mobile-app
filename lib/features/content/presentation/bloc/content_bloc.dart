import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_brands_usecase.dart';
import '../../domain/usecases/get_company_info_usecase.dart';
import '../../domain/usecases/get_faqs_usecase.dart';
import '../../domain/usecases/get_packages_usecase.dart';
import '../../domain/usecases/get_projects_usecase.dart';
import '../../domain/usecases/get_solutions_usecase.dart';
import 'content_event.dart';
import 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final GetCompanyInfoUseCase getCompanyInfo;
  final GetPackagesUseCase getPackages;
  final GetSolutionsUseCase getSolutions;
  final GetProjectsUseCase getProjects;
  final GetFaqsUseCase getFaqs;
  final GetBrandsUseCase getBrands;

  ContentBloc(
    this.getCompanyInfo,
    this.getPackages,
    this.getSolutions,
    this.getProjects,
    this.getFaqs,
    this.getBrands,
  ) : super(const ContentState()) {
    on<LoadCompanyInfoEvent>(_onLoadCompanyInfo);
    on<LoadPackagesEvent>(_onLoadPackages);
    on<LoadSolutionsEvent>(_onLoadSolutions);
    on<LoadProjectsEvent>(_onLoadProjects);
    on<LoadFaqsEvent>(_onLoadFaqs);
    on<LoadBrandsEvent>(_onLoadBrands);
  }

  Future<void> _onLoadCompanyInfo(
    LoadCompanyInfoEvent event,
    Emitter<ContentState> emit,
  ) async {
    if (state.companyStatus == LoadStatus.success) return;
    emit(state.copyWith(companyStatus: LoadStatus.loading));
    final result = await getCompanyInfo();
    result.fold(
      (failure) => emit(state.copyWith(
        companyStatus: LoadStatus.failure,
        companyError: failure.message,
      )),
      (info) => emit(state.copyWith(companyStatus: LoadStatus.success, companyInfo: info)),
    );
  }

  Future<void> _onLoadPackages(
    LoadPackagesEvent event,
    Emitter<ContentState> emit,
  ) async {
    if (state.packagesStatus == LoadStatus.success) return;
    emit(state.copyWith(packagesStatus: LoadStatus.loading));
    final result = await getPackages();
    result.fold(
      (failure) => emit(state.copyWith(
        packagesStatus: LoadStatus.failure,
        packagesError: failure.message,
      )),
      (list) => emit(state.copyWith(packagesStatus: LoadStatus.success, packages: list)),
    );
  }

  Future<void> _onLoadSolutions(
    LoadSolutionsEvent event,
    Emitter<ContentState> emit,
  ) async {
    if (state.solutionsStatus == LoadStatus.success) return;
    emit(state.copyWith(solutionsStatus: LoadStatus.loading));
    final result = await getSolutions();
    result.fold(
      (failure) => emit(state.copyWith(
        solutionsStatus: LoadStatus.failure,
        solutionsError: failure.message,
      )),
      (list) => emit(state.copyWith(solutionsStatus: LoadStatus.success, solutions: list)),
    );
  }

  Future<void> _onLoadProjects(
    LoadProjectsEvent event,
    Emitter<ContentState> emit,
  ) async {
    if (state.projectsStatus == LoadStatus.success) return;
    emit(state.copyWith(projectsStatus: LoadStatus.loading));
    final result = await getProjects();
    result.fold(
      (failure) => emit(state.copyWith(
        projectsStatus: LoadStatus.failure,
        projectsError: failure.message,
      )),
      (list) => emit(state.copyWith(projectsStatus: LoadStatus.success, projects: list)),
    );
  }

  Future<void> _onLoadFaqs(LoadFaqsEvent event, Emitter<ContentState> emit) async {
    if (state.faqsStatus == LoadStatus.success) return;
    emit(state.copyWith(faqsStatus: LoadStatus.loading));
    final result = await getFaqs();
    result.fold(
      (failure) =>
          emit(state.copyWith(faqsStatus: LoadStatus.failure, faqsError: failure.message)),
      (list) => emit(state.copyWith(faqsStatus: LoadStatus.success, faqs: list)),
    );
  }

  Future<void> _onLoadBrands(LoadBrandsEvent event, Emitter<ContentState> emit) async {
    if (state.brandsStatus == LoadStatus.success) return;
    emit(state.copyWith(brandsStatus: LoadStatus.loading));
    final result = await getBrands();
    result.fold(
      (failure) =>
          emit(state.copyWith(brandsStatus: LoadStatus.failure, brandsError: failure.message)),
      (list) => emit(state.copyWith(brandsStatus: LoadStatus.success, brands: list)),
    );
  }
}
