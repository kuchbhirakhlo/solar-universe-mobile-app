import 'package:equatable/equatable.dart';

abstract class StaffDashboardEvent extends Equatable {
  const StaffDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffDashboardEvent extends StaffDashboardEvent {
  const LoadStaffDashboardEvent();
}
