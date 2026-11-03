import 'package:equatable/equatable.dart';
import '../../../staff_enquiries/domain/entities/staff_enquiry_entity.dart';

enum StaffDashboardStatus { initial, loading, success, failure }

class StaffDashboardState extends Equatable {
  final StaffDashboardStatus status;
  final int totalEnquiries;
  final int myEnquiries;
  final int solarCustomers;
  final int convertedLeads;
  final List<StaffEnquiryEntity> recentEnquiries;
  final String? errorMessage;

  const StaffDashboardState({
    this.status = StaffDashboardStatus.initial,
    this.totalEnquiries = 0,
    this.myEnquiries = 0,
    this.solarCustomers = 0,
    this.convertedLeads = 0,
    this.recentEnquiries = const [],
    this.errorMessage,
  });

  StaffDashboardState copyWith({
    StaffDashboardStatus? status,
    int? totalEnquiries,
    int? myEnquiries,
    int? solarCustomers,
    int? convertedLeads,
    List<StaffEnquiryEntity>? recentEnquiries,
    String? errorMessage,
  }) {
    return StaffDashboardState(
      status: status ?? this.status,
      totalEnquiries: totalEnquiries ?? this.totalEnquiries,
      myEnquiries: myEnquiries ?? this.myEnquiries,
      solarCustomers: solarCustomers ?? this.solarCustomers,
      convertedLeads: convertedLeads ?? this.convertedLeads,
      recentEnquiries: recentEnquiries ?? this.recentEnquiries,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        totalEnquiries,
        myEnquiries,
        solarCustomers,
        convertedLeads,
        recentEnquiries,
        errorMessage,
      ];
}
