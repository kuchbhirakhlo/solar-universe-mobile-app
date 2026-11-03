import 'package:equatable/equatable.dart';

class PackageEntity extends Equatable {
  final String id;
  final String title;
  final String capacity;
  final num price;
  final String panelType;
  final String inverter;
  final String warranty;
  final List<String> features;

  const PackageEntity({
    required this.id,
    required this.title,
    required this.capacity,
    required this.price,
    required this.panelType,
    required this.inverter,
    required this.warranty,
    required this.features,
  });

  @override
  List<Object?> get props => [id, title, capacity, price, panelType, inverter, warranty, features];
}
