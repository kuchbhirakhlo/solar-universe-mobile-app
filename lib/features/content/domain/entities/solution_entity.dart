import 'package:equatable/equatable.dart';

class SolutionEntity extends Equatable {
  final String id;
  final String type;
  final String title;
  final String description;
  final List<String> benefits;
  final int order;

  const SolutionEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.benefits,
    required this.order,
  });

  @override
  List<Object?> get props => [id, type, title, description, benefits, order];
}
