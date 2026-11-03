import 'package:equatable/equatable.dart';

class BrandEntity extends Equatable {
  final String id;
  final String name;
  final String logo;
  final String website;

  const BrandEntity({
    required this.id,
    required this.name,
    required this.logo,
    required this.website,
  });

  @override
  List<Object?> get props => [id, name, logo, website];
}
