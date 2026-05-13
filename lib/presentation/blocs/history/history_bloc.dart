import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/api/api_client.dart';

// --- Events ---
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class HistoryLoadRequested extends HistoryEvent {}

// --- States ---
abstract class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<dynamic> games;
  const HistoryLoaded(this.games);
  @override
  List<Object?> get props => [games];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final ApiClient _api = ApiClient();

  HistoryBloc() : super(HistoryInitial()) {
    on<HistoryLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(HistoryLoadRequested event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final games = await _api.getHistory();
      emit(HistoryLoaded(games));
    } catch (e) {
      emit(HistoryError(e is ApiException ? e.message : e.toString()));
    }
  }
}
