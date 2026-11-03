import 'package:equatable/equatable.dart';

class QuotationItemEntity extends Equatable {
  final String item;
  final String spec;
  final String qty;

  const QuotationItemEntity({required this.item, required this.spec, required this.qty});

  Map<String, dynamic> toMap() => {'item': item, 'spec': spec, 'qty': qty};

  factory QuotationItemEntity.fromMap(Map<String, dynamic> map) => QuotationItemEntity(
        item: map['item'] as String? ?? '',
        spec: map['spec'] as String? ?? '',
        qty: map['qty'] as String? ?? '',
      );

  @override
  List<Object?> get props => [item, spec, qty];
}

class QuotationEntity extends Equatable {
  final String id;
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
  final String quotationNumber;
  final String preparedBy;
  final String? createdByStaffId;
  final String createdAt;

  const QuotationEntity({
    required this.id,
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
    required this.quotationNumber,
    required this.preparedBy,
    this.createdByStaffId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        customerName,
        phone,
        solarSystem,
        capacity,
        products,
        items,
        price,
        gst,
        discount,
        finalAmount,
        quotationNumber,
        preparedBy,
        createdByStaffId,
        createdAt,
      ];
}
