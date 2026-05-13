import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/api/api_client.dart';

// --- Events ---
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileUpgradeRequested extends ProfileEvent {}

// --- States ---
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> user;
  final Map<String, dynamic> stats;
  final List<dynamic> achievements;

  const ProfileLoaded({
    required this.user,
    required this.stats,
    required this.achievements,
  });

  @override
  List<Object?> get props => [user, stats, achievements];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiClient _api = ApiClient();

  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpgradeRequested>(_onUpgradeRequested);
  }

  Future<void> _onLoadRequested(ProfileLoadRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = await _api.getMe();
      final stats = await _api.getStats();
      final achievements = await _api.getAchievements();
      
      emit(ProfileLoaded(
        user: user,
        stats: stats,
        achievements: achievements,
      ));
    } catch (e) {
      emit(ProfileError(e is ApiException ? e.message : e.toString()));
    }
  }

  Future<void> _onUpgradeRequested(ProfileUpgradeRequested event, Emitter<ProfileState> emit) async {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;
    
    emit(ProfileLoading());
    try {
      final updatedUser = await _api.upgradePro();
      emit(ProfileLoaded(
        user: updatedUser,
        stats: currentState.stats,
        achievements: currentState.achievements,
      ));
    } catch (e) {
      emit(ProfileError(e is ApiException ? e.message : e.toString()));
      emit(currentState); // fallback
    }
  }
}
