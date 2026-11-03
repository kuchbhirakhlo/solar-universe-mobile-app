import '../../domain/entities/package_entity.dart';

class PackageModel extends PackageEntity {
  const PackageModel({
    required super.id,
    required super.title,
    required super.capacity,
    required super.price,
    required super.panelType,
    required super.inverter,
    required super.warranty,
    required super.features,
  });

  factory PackageModel.fromMap(String id, Map<String, dynamic> map) {
    return PackageModel(
      id: id,
      title: map['title'] as String? ?? '',
      capacity: map['capacity'] as String? ?? '',
      price: map['price'] as num? ?? 0,
      panelType: map['panelType'] as String? ?? '',
      inverter: map['inverter'] as String? ?? '',
      warranty: map['warranty'] as String? ?? '',
      features: List<String>.from(map['features'] as List? ?? const []),
    );
  }
}
