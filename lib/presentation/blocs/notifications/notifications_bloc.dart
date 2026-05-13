import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/api/api_client.dart';

// Events
abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => [];
}

class NotificationsLoadRequested extends NotificationsEvent {}

class NotificationsMarkAllReadRequested extends NotificationsEvent {}

// States
abstract class NotificationsState extends Equatable {
  const NotificationsState();
  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<dynamic> notifications;
  const NotificationsLoaded(this.notifications);
  @override
  List<Object?> get props => [notifications];
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final ApiClient _api = ApiClient();

  NotificationsBloc() : super(NotificationsInitial()) {
    on<NotificationsLoadRequested>(_onLoadRequested);
    on<NotificationsMarkAllReadRequested>(_onMarkAllReadRequested);
  }

  Future<void> _onLoadRequested(NotificationsLoadRequested event, Emitter<NotificationsState> emit) async {
    emit(NotificationsLoading());
    try {
      final notifs = await _api.getNotifications();
      emit(NotificationsLoaded(notifs));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onMarkAllReadRequested(NotificationsMarkAllReadRequested event, Emitter<NotificationsState> emit) async {
    if (state is NotificationsLoaded) {
      try {
        await _api.markNotificationsRead();
        final notifs = await _api.getNotifications();
        emit(NotificationsLoaded(notifs));
      } catch (_) {}
    }
  }
}
