import '../../domain/entities/faq_entity.dart';

class FaqModel extends FaqEntity {
  const FaqModel({
    required super.id,
    required super.question,
    required super.answer,
  });

  factory FaqModel.fromMap(String id, Map<String, dynamic> map) {
    return FaqModel(
      id: id,
      question: map['question'] as String? ?? '',
      answer: map['answer'] as String? ?? '',
    );
  }
}
