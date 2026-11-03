import 'package:equatable/equatable.dart';
import '../../domain/entities/quotation_entity.dart';

enum ListStatus { initial, loading, success, failure }
enum SaveStatus { initial, saving, success, failure }

class QuickQuoteState extends Equatable {
  final ListStatus listStatus;
  final List<QuotationEntity> quotations;
  final String? listError;
  final SaveStatus saveStatus;
  final String? saveError;
  final QuotationEntity? lastSaved;

  const QuickQuoteState({
    this.listStatus = ListStatus.initial,
    this.quotations = const [],
    this.listError,
    this.saveStatus = SaveStatus.initial,
    this.saveError,
    this.lastSaved,
  });

  QuickQuoteState copyWith({
    ListStatus? listStatus,
    List<QuotationEntity>? quotations,
    String? listError,
    SaveStatus? saveStatus,
    String? saveError,
    QuotationEntity? lastSaved,
  }) {
    return QuickQuoteState(
      listStatus: listStatus ?? this.listStatus,
      quotations: quotations ?? this.quotations,
      listError: listError,
      saveStatus: saveStatus ?? this.saveStatus,
      saveError: saveError,
      lastSaved: lastSaved ?? this.lastSaved,
    );
  }

  @override
  List<Object?> get props =>
      [listStatus, quotations, listError, saveStatus, saveError, lastSaved];
}
