import 'package:equatable/equatable.dart';

abstract class ContentEvent extends Equatable {
  const ContentEvent();

  @override
  List<Object?> get props => [];
}

class LoadCompanyInfoEvent extends ContentEvent {
  const LoadCompanyInfoEvent();
}

class LoadPackagesEvent extends ContentEvent {
  const LoadPackagesEvent();
}

class LoadSolutionsEvent extends ContentEvent {
  const LoadSolutionsEvent();
}

class LoadProjectsEvent extends ContentEvent {
  const LoadProjectsEvent();
}

class LoadFaqsEvent extends ContentEvent {
  const LoadFaqsEvent();
}

class LoadBrandsEvent extends ContentEvent {
  const LoadBrandsEvent();
}
