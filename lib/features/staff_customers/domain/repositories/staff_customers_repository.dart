import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff_customer_entity.dart';

/// No document fields here anymore — every document is uploaded as soon as
/// it's picked (via [StaffCustomersRepository.uploadDocument], against a
/// [StaffCustomersRepository.reserveCustomerId]'d customer ID), not bundled
/// up and uploaded when this is submitted. This is just the metadata write.
class NewStaffCustomer {
  final String name;
  final String mobile;
  final String email;
  final String address;
  final String systemType;
  final String capacity;

  const NewStaffCustomer({
    required this.name,
    required this.mobile,
    required this.email,
    required this.address,
    required this.systemType,
    required this.capacity,
  });
}

abstract class StaffCustomersRepository {
  /// Returns only customers registered by the currently signed-in staff
  /// member — this app scopes every staff feature to its creator.
  Future<Either<Failure, List<StaffCustomerEntity>>> getCustomers();

  /// A locally-generated customer ID the Create Customer form can start
  /// uploading documents against immediately, before Register is pressed.
  String reserveCustomerId();

  /// Writes the customer's metadata onto [customerId] — see [NewStaffCustomer].
  Future<Either<Failure, void>> createCustomer(
    NewStaffCustomer customer, {
    required String customerId,
  });

  /// Uploads/replaces a single document — used both by the registration
  /// form (uploading eagerly, as each file is picked) and the customer
  /// detail view (adding/replacing a document post-registration).
  Future<Either<Failure, void>> uploadDocument({
    required String customerId,
    required String docType,
    required String filePath,
    bool multi = false,
  });
}
