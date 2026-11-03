import '../../domain/entities/solution_entity.dart';

class SolutionModel extends SolutionEntity {
  const SolutionModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.benefits,
    required super.order,
  });

  factory SolutionModel.fromMap(String id, Map<String, dynamic> map) {
    return SolutionModel(
      id: id,
      type: map['type'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      benefits: List<String>.from(map['benefits'] as List? ?? const []),
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }
}
