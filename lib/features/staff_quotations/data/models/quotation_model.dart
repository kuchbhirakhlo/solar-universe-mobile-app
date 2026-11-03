import '../../domain/entities/quotation_entity.dart';

class QuotationModel extends QuotationEntity {
  const QuotationModel({
    required super.id,
    required super.customerName,
    required super.phone,
    required super.solarSystem,
    required super.capacity,
    required super.products,
    required super.items,
    required super.price,
    required super.gst,
    required super.discount,
    required super.finalAmount,
    required super.quotationNumber,
    required super.preparedBy,
    super.createdByStaffId,
    required super.createdAt,
  });

  factory QuotationModel.fromMap(String id, Map<String, dynamic> map) {
    return QuotationModel(
      id: id,
      customerName: map['customerName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      solarSystem: map['solarSystem'] as String? ?? '',
      capacity: map['capacity'] as String? ?? '',
      products: map['products'] as String? ?? '',
      items: ((map['items'] as List?) ?? const [])
          .map((e) => QuotationItemEntity.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      price: map['price'] as num? ?? 0,
      gst: map['gst'] as num? ?? 0,
      discount: map['discount'] as num? ?? 0,
      finalAmount: map['finalAmount'] as num? ?? 0,
      quotationNumber: map['quotationNumber'] as String? ?? '',
      preparedBy: map['preparedBy'] as String? ?? '',
      createdByStaffId: map['createdByStaffId'] as String?,
      createdAt: map['createdAt'] as String? ?? '',
    );
  }
}
