import 'package:equatable/equatable.dart';

class FaqEntity extends Equatable {
  final String id;
  final String question;
  final String answer;

  const FaqEntity({
    required this.id,
    required this.question,
    required this.answer,
  });

  @override
  List<Object?> get props => [id, question, answer];
}
