import '../../domain/entities/brand_entity.dart';

class BrandModel extends BrandEntity {
  const BrandModel({
    required super.id,
    required super.name,
    required super.logo,
    required super.website,
  });

  factory BrandModel.fromMap(String id, Map<String, dynamic> map) {
    return BrandModel(
      id: id,
      name: map['name'] as String? ?? '',
      logo: map['logo'] as String? ?? '',
      website: map['website'] as String? ?? '',
    );
  }
}
