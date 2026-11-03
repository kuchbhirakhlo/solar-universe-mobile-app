import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  final String id;
  final String title;
  final String location;
  final String systemType;
  final String category;
  final String capacity;
  final String imageUrl;
  final bool featured;
  final String customerName;
  final String completionDate;
  final String description;

  const ProjectEntity({
    required this.id,
    required this.title,
    required this.location,
    required this.systemType,
    this.category = '',
    required this.capacity,
    required this.imageUrl,
    required this.featured,
    required this.customerName,
    required this.completionDate,
    required this.description,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        location,
        systemType,
        category,
        capacity,
        imageUrl,
        featured,
        customerName,
        completionDate,
        description,
      ];
}
