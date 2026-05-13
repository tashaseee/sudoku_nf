import 'package:equatable/equatable.dart';
import '../../../core/sudoku/sudoku_generator.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class NewGameEvent extends GameEvent {
  final Difficulty difficulty;
  const NewGameEvent(this.difficulty);

  @override
  List<Object?> get props => [difficulty];
}

class InputNumberEvent extends GameEvent {
  final int number;
  const InputNumberEvent(this.number);

  @override
  List<Object?> get props => [number];
}

class SelectCellEvent extends GameEvent {
  final int row;
  final int col;
  const SelectCellEvent(this.row, this.col);

  @override
  List<Object?> get props => [row, col];
}

class ToggleNotesModeEvent extends GameEvent {}

class EraseCellEvent extends GameEvent {}

class UseHintEvent extends GameEvent {}

class TimerTickEvent extends GameEvent {}

class AutoFillNotesEvent extends GameEvent {}

class RequestAICoachEvent extends GameEvent {}

class DismissAICoachEvent extends GameEvent {}
