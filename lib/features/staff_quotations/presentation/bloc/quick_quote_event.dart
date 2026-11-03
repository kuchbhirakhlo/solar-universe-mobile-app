import 'package:equatable/equatable.dart';
import '../../domain/repositories/staff_quotations_repository.dart';

abstract class QuickQuoteEvent extends Equatable {
  const QuickQuoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuotationsEvent extends QuickQuoteEvent {
  const LoadQuotationsEvent();
}

class SaveQuotationEvent extends QuickQuoteEvent {
  final NewQuotation quotation;
  const SaveQuotationEvent(this.quotation);

  @override
  List<Object?> get props => [quotation];
}

class ResetQuotationSaveStatusEvent extends QuickQuoteEvent {
  const ResetQuotationSaveStatusEvent();
}
