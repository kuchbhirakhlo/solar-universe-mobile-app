import '../../domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.title,
    required super.location,
    required super.systemType,
    super.category,
    required super.capacity,
    required super.imageUrl,
    required super.featured,
    required super.customerName,
    required super.completionDate,
    required super.description,
  });

  factory ProjectModel.fromMap(String id, Map<String, dynamic> map) {
    return ProjectModel(
      id: id,
      title: map['title'] as String? ?? '',
      location: map['location'] as String? ?? '',
      systemType: map['systemType'] as String? ?? '',
      category: map['category'] as String? ?? '',
      capacity: map['capacity'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      featured: map['featured'] as bool? ?? false,
      customerName: map['customerName'] as String? ?? '',
      completionDate: map['completionDate'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }
}
