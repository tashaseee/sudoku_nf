import 'package:equatable/equatable.dart';

class SudokuCell extends Equatable {
  final int row;
  final int col;
  final int value;
  final int correctValue;
  final bool isInitial;
  final Set<int> notes;
  final bool isError;

  const SudokuCell({
    required this.row,
    required this.col,
    required this.value,
    required this.correctValue,
    required this.isInitial,
    required this.notes,
    required this.isError,
  });

  SudokuCell copyWith({int? value, bool? isError, Set<int>? notes}) {
    return SudokuCell(
      row: row,
      col: col,
      value: value ?? this.value,
      correctValue: correctValue,
      isInitial: isInitial,
      notes: notes ?? this.notes,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props => [
    row,
    col,
    value,
    correctValue,
    isInitial,
    notes,
    isError,
  ];
}
