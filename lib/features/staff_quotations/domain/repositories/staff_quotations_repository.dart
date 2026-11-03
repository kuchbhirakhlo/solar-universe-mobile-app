import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/quotation_entity.dart';

class NewQuotation {
  final String customerName;
  final String phone;
  final String solarSystem;
  final String capacity;
  final String products;
  final List<QuotationItemEntity> items;
  final num price;
  final num gst;
  final num discount;
  final num finalAmount;

  const NewQuotation({
    required this.customerName,
    required this.phone,
    required this.solarSystem,
    required this.capacity,
    required this.products,
    required this.items,
    required this.price,
    required this.gst,
    required this.discount,
    required this.finalAmount,
  });
}

abstract class StaffQuotationsRepository {
  Future<Either<Failure, List<QuotationEntity>>> getQuotations();
  Future<Either<Failure, QuotationEntity>> createQuotation(NewQuotation quotation);
}
