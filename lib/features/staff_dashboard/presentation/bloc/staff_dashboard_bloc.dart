import '../../../staff_enquiries/domain/enquiry_stages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/staff_session.dart';
import '../../../staff_customers/domain/entities/staff_customer_entity.dart';
import '../../../staff_customers/domain/repositories/staff_customers_repository.dart';
import '../../../staff_enquiries/domain/entities/staff_enquiry_entity.dart';
import '../../../staff_enquiries/domain/repositories/staff_enquiries_repository.dart';
import 'staff_dashboard_event.dart';
import 'staff_dashboard_state.dart';

class StaffDashboardBloc extends Bloc<StaffDashboardEvent, StaffDashboardState> {
  final StaffEnquiriesRepository enquiriesRepository;
  final StaffCustomersRepository customersRepository;
  final StaffSession session;

  StaffDashboardBloc(this.enquiriesRepository, this.customersRepository, this.session)
      : super(const StaffDashboardState()) {
    on<LoadStaffDashboardEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadStaffDashboardEvent event, Emitter<StaffDashboardState> emit) async {
    emit(state.copyWith(status: StaffDashboardStatus.loading));
    final staffId = session.current?.id;

    final enquiriesResult = await enquiriesRepository.getEnquiries();
    final customersResult = await customersRepository.getCustomers();

    final enquiriesFailure = enquiriesResult.fold((f) => f, (_) => null);
    final customersFailure = customersResult.fold((f) => f, (_) => null);
    if (enquiriesFailure != null && customersFailure != null) {
      emit(state.copyWith(
        status: StaffDashboardStatus.failure,
        errorMessage: enquiriesFailure.message,
      ));
      return;
    }

    final enquiries = enquiriesResult.fold(
      (_) => const <StaffEnquiryEntity>[],
      (list) => list,
    );
    final customers = customersResult.fold(
      (_) => const <StaffCustomerEntity>[],
      (list) => list,
    );

    emit(state.copyWith(
      status: StaffDashboardStatus.success,
      totalEnquiries: enquiries.length,
      myEnquiries: enquiries.where((e) => e.createdByStaffId == staffId).length,
      solarCustomers: customers.length,
      convertedLeads: enquiries.where((e) => EnquiryStages.isConverted(e.status)).length,
      recentEnquiries: enquiries.take(5).toList(),
    ));
  }
}
