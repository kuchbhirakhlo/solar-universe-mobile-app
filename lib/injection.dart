import 'core/services/staff_location_tracker.dart';
import 'features/staff_auth/data/datasources/staff_location_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:solaruniverse/core/network/network_info.dart';
import 'package:solaruniverse/core/session/customer_session.dart';
import 'package:solaruniverse/core/session/staff_session.dart';
import 'package:solaruniverse/features/content/data/datasources/content_datasource.dart';
import 'package:solaruniverse/features/content/data/repositories/content_repository_impl.dart';
import 'package:solaruniverse/features/content/domain/repositories/content_repository.dart';
import 'package:solaruniverse/features/content/domain/usecases/get_brands_usecase.dart';
import 'package:solaruniverse/features/content/domain/usecases/get_company_info_usecase.dart';
import 'package:solaruniverse/features/content/domain/usecases/get_faqs_usecase.dart';
import 'package:solaruniverse/features/content/domain/usecases/get_packages_usecase.dart';
import 'package:solaruniverse/features/content/domain/usecases/get_projects_usecase.dart';
import 'package:solaruniverse/features/content/domain/usecases/get_solutions_usecase.dart';
import 'package:solaruniverse/features/content/presentation/bloc/content_bloc.dart';
import 'package:solaruniverse/features/customer_auth/data/datasources/customer_auth_datasource.dart';
import 'package:solaruniverse/features/customer_auth/data/repositories/customer_auth_repository_impl.dart';
import 'package:solaruniverse/features/customer_auth/domain/repositories/customer_auth_repository.dart';
import 'package:solaruniverse/features/customer_auth/domain/usecases/create_customer_profile_usecase.dart';
import 'package:solaruniverse/features/customer_auth/domain/usecases/get_current_customer_usecase.dart';
import 'package:solaruniverse/features/customer_auth/domain/usecases/send_customer_otp_usecase.dart';
import 'package:solaruniverse/features/customer_auth/domain/usecases/sign_out_customer_usecase.dart';
import 'package:solaruniverse/features/customer_auth/domain/usecases/verify_customer_otp_usecase.dart';
import 'package:solaruniverse/features/customer_auth/presentation/bloc/customer_auth_bloc.dart';
import 'package:solaruniverse/features/customer_service_requests/data/datasources/customer_service_requests_datasource.dart';
import 'package:solaruniverse/features/customer_service_requests/data/repositories/customer_service_requests_repository_impl.dart';
import 'package:solaruniverse/features/customer_service_requests/domain/repositories/customer_service_requests_repository.dart';
import 'package:solaruniverse/features/customer_service_requests/domain/usecases/create_service_request_usecase.dart';
import 'package:solaruniverse/features/customer_service_requests/domain/usecases/get_my_service_requests_usecase.dart';
import 'package:solaruniverse/features/customer_service_requests/presentation/bloc/customer_service_requests_bloc.dart';
import 'package:solaruniverse/features/enquiry/data/datasources/enquiry_datasource.dart';
import 'package:solaruniverse/features/enquiry/data/repositories/enquiry_repository_impl.dart';
import 'package:solaruniverse/features/enquiry/domain/repositories/enquiry_repository.dart';
import 'package:solaruniverse/features/enquiry/domain/usecases/submit_contact_message_usecase.dart';
import 'package:solaruniverse/features/enquiry/domain/usecases/submit_enquiry_usecase.dart';
import 'package:solaruniverse/features/enquiry/presentation/bloc/enquiry_bloc.dart';
import 'package:solaruniverse/features/staff_auth/data/datasources/attendance_datasource.dart';
import 'package:solaruniverse/features/staff_auth/data/datasources/staff_auth_datasource.dart';
import 'package:solaruniverse/features/staff_auth/data/repositories/staff_auth_repository_impl.dart';
import 'package:solaruniverse/features/staff_auth/domain/repositories/staff_auth_repository.dart';
import 'package:solaruniverse/features/staff_auth/domain/usecases/get_current_staff_usecase.dart';
import 'package:solaruniverse/features/staff_auth/domain/usecases/sign_in_staff_usecase.dart';
import 'package:solaruniverse/features/staff_auth/domain/usecases/sign_out_staff_usecase.dart';
import 'package:solaruniverse/features/staff_auth/presentation/bloc/staff_auth_bloc.dart';
import 'package:solaruniverse/features/staff_customers/data/datasources/staff_customers_datasource.dart';
import 'package:solaruniverse/features/staff_customers/data/repositories/staff_customers_repository_impl.dart';
import 'package:solaruniverse/features/staff_customers/domain/repositories/staff_customers_repository.dart';
import 'package:solaruniverse/features/staff_customers/presentation/bloc/staff_customers_bloc.dart';
import 'package:solaruniverse/features/staff_dashboard/presentation/bloc/staff_dashboard_bloc.dart';
import 'package:solaruniverse/features/staff_enquiries/data/datasources/staff_enquiries_datasource.dart';
import 'package:solaruniverse/features/staff_enquiries/data/repositories/staff_enquiries_repository_impl.dart';
import 'package:solaruniverse/features/staff_enquiries/domain/repositories/staff_enquiries_repository.dart';
import 'package:solaruniverse/features/staff_enquiries/presentation/bloc/staff_enquiries_bloc.dart';
import 'package:solaruniverse/features/staff_quotations/data/datasources/staff_quotations_datasource.dart';
import 'package:solaruniverse/features/staff_quotations/data/repositories/staff_quotations_repository_impl.dart';
import 'package:solaruniverse/features/staff_quotations/domain/repositories/staff_quotations_repository.dart';
import 'package:solaruniverse/features/staff_quotations/presentation/bloc/quick_quote_bloc.dart';
import 'package:solaruniverse/features/staff_service_requests/data/datasources/staff_service_requests_datasource.dart';
import 'package:solaruniverse/features/staff_service_requests/data/repositories/staff_service_requests_repository_impl.dart';
import 'package:solaruniverse/features/staff_service_requests/domain/repositories/staff_service_requests_repository.dart';
import 'package:solaruniverse/features/staff_service_requests/domain/usecases/get_assigned_service_requests_usecase.dart';
import 'package:solaruniverse/features/staff_service_requests/domain/usecases/update_service_request_usecase.dart';
import 'package:solaruniverse/features/staff_service_requests/domain/usecases/upload_installation_photo_usecase.dart';
import 'package:solaruniverse/features/staff_service_requests/presentation/bloc/staff_service_requests_bloc.dart';
import 'package:solaruniverse/features/staff_service_requests/presentation/bloc/staff_service_requests_event.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Firebase
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => StaffSession());
  sl.registerLazySingleton(() => CustomerSession());

  // --- Content ---
  sl.registerLazySingleton<ContentDataSource>(() => ContentDataSourceImpl(sl()));
  sl.registerLazySingleton<ContentRepository>(() => ContentRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetCompanyInfoUseCase(sl()));
  sl.registerLazySingleton(() => GetPackagesUseCase(sl()));
  sl.registerLazySingleton(() => GetSolutionsUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectsUseCase(sl()));
  sl.registerLazySingleton(() => GetFaqsUseCase(sl()));
  sl.registerLazySingleton(() => GetBrandsUseCase(sl()));
  // Singleton so content stays cached as the user moves between screens.
  sl.registerLazySingleton(() => ContentBloc(sl(), sl(), sl(), sl(), sl(), sl()));

  // --- Enquiry ---
  sl.registerLazySingleton<EnquiryDataSource>(() => EnquiryDataSourceImpl(sl()));
  sl.registerLazySingleton<EnquiryRepository>(() => EnquiryRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => SubmitEnquiryUseCase(sl()));
  sl.registerLazySingleton(() => SubmitContactMessageUseCase(sl()));
  sl.registerFactory(() => EnquiryBloc(sl(), sl()));

  // --- Staff Auth ---
  sl.registerLazySingleton<StaffAuthDataSource>(() => StaffAuthDataSourceImpl(sl(), sl()));
  sl.registerLazySingleton<StaffAuthRepository>(() => StaffAuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => SignInStaffUseCase(sl()));
  sl.registerLazySingleton(() => SignOutStaffUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentStaffUseCase(sl()));
  sl.registerLazySingleton(() => AttendanceDataSource(sl()));
  sl.registerLazySingleton(() => StaffLocationDataSource(sl()));
  sl.registerLazySingleton(() => StaffLocationTracker(sl()));
  sl.registerFactory(
    () => StaffAuthBloc(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      onSignedOut: () => sl<StaffServiceRequestsBloc>().add(
        const ResetAssignedServiceRequestsEvent(),
      ),
    ),
  );

  // --- Staff Enquiries ---
  sl.registerLazySingleton<StaffEnquiriesDataSource>(() => StaffEnquiriesDataSourceImpl(sl(), sl()));
  sl.registerLazySingleton<StaffEnquiriesRepository>(
    () => StaffEnquiriesRepositoryImpl(
      sl(),
      sl(),
      () => sl<StaffSession>().current?.id ?? '',
      () => sl<StaffSession>().current?.name ?? '',
    ),
  );
  // Singleton so the list refreshes itself after a create, and both the
  // dashboard's shortcut and the Enquiries tab share the same fetched list.
  sl.registerLazySingleton(() => StaffEnquiriesBloc(sl()));

  // --- Staff Customers ---
  sl.registerLazySingleton<StaffCustomersDataSource>(
    () => StaffCustomersDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<StaffCustomersRepository>(
    () => StaffCustomersRepositoryImpl(sl(), sl(), () => sl<StaffSession>().current?.id ?? ''),
  );
  sl.registerLazySingleton(() => StaffCustomersBloc(sl()));

  // --- Staff Dashboard ---
  sl.registerFactory(() => StaffDashboardBloc(sl(), sl(), sl()));

  // --- Staff Quotations ---
  sl.registerLazySingleton<StaffQuotationsDataSource>(() => StaffQuotationsDataSourceImpl(sl()));
  sl.registerLazySingleton<StaffQuotationsRepository>(
    () => StaffQuotationsRepositoryImpl(
      sl(),
      sl(),
      () => sl<StaffSession>().current?.id ?? '',
      () => sl<StaffSession>().current?.name ?? '',
    ),
  );
  sl.registerFactory(() => QuickQuoteBloc(sl()));

  // --- Customer Auth ---
  sl.registerLazySingleton<CustomerAuthDataSource>(() => CustomerAuthDataSourceImpl(sl(), sl()));
  sl.registerLazySingleton<CustomerAuthRepository>(() => CustomerAuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => SendCustomerOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyCustomerOtpUseCase(sl()));
  sl.registerLazySingleton(() => CreateCustomerProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentCustomerUseCase(sl()));
  sl.registerLazySingleton(() => SignOutCustomerUseCase(sl()));
  // Singleton, not factory — the login -> OTP flow spans two separately
  // routed screens that both need to observe the same bloc instance (see
  // the doc comment on CustomerLoginScreen).
  sl.registerLazySingleton(() => CustomerAuthBloc(sl(), sl(), sl(), sl(), sl()));

  // --- Customer Service Requests ---
  sl.registerLazySingleton<CustomerServiceRequestsDataSource>(
    () => CustomerServiceRequestsDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CustomerServiceRequestsRepository>(
    () => CustomerServiceRequestsRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => GetMyServiceRequestsUseCase(sl()));
  sl.registerLazySingleton(() => CreateServiceRequestUseCase(sl()));
  // Singleton so the dashboard's list and the Create Service Request screen
  // (a separately routed, pushed screen) share the same bloc instance.
  sl.registerLazySingleton(() => CustomerServiceRequestsBloc(sl(), sl()));

  // --- Staff Service Requests (Engineer role) ---
  sl.registerLazySingleton<StaffServiceRequestsDataSource>(
    () => StaffServiceRequestsDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<StaffServiceRequestsRepository>(
    () => StaffServiceRequestsRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => GetAssignedServiceRequestsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateServiceRequestUseCase(sl()));
  sl.registerLazySingleton(() => UploadInstallationPhotoUseCase(sl()));
  // Singleton so the list screen and the pushed detail screen share the
  // same bloc instance (same reasoning as CustomerServiceRequestsBloc).
  sl.registerLazySingleton(() => StaffServiceRequestsBloc(sl(), sl(), sl()));
}
