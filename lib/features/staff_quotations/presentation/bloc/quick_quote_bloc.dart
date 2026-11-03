import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/staff_quotations_repository.dart';
import 'quick_quote_event.dart';
import 'quick_quote_state.dart';

class QuickQuoteBloc extends Bloc<QuickQuoteEvent, QuickQuoteState> {
  final StaffQuotationsRepository repository;

  QuickQuoteBloc(this.repository) : super(const QuickQuoteState()) {
    on<LoadQuotationsEvent>(_onLoad);
    on<SaveQuotationEvent>(_onSave);
    on<ResetQuotationSaveStatusEvent>(
      (event, emit) => emit(state.copyWith(saveStatus: SaveStatus.initial)),
    );
  }

  Future<void> _onLoad(LoadQuotationsEvent event, Emitter<QuickQuoteState> emit) async {
    emit(state.copyWith(listStatus: ListStatus.loading));
    final result = await repository.getQuotations();
    result.fold(
      (failure) =>
          emit(state.copyWith(listStatus: ListStatus.failure, listError: failure.message)),
      (list) => emit(state.copyWith(listStatus: ListStatus.success, quotations: list)),
    );
  }

  Future<void> _onSave(SaveQuotationEvent event, Emitter<QuickQuoteState> emit) async {
    emit(state.copyWith(saveStatus: SaveStatus.saving));
    final result = await repository.createQuotation(event.quotation);
    await result.fold(
      (failure) async {
        emit(state.copyWith(saveStatus: SaveStatus.failure, saveError: failure.message));
      },
      (saved) async {
        emit(state.copyWith(saveStatus: SaveStatus.success, lastSaved: saved));
        add(const LoadQuotationsEvent());
      },
    );
  }
}
