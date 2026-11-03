import 'package:equatable/equatable.dart';
import '../constants/app_strings.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = AppStrings.errorUnknown]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = AppStrings.errorOffline]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = AppStrings.errorUnknown]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = AppStrings.errorUnknown]);
}
