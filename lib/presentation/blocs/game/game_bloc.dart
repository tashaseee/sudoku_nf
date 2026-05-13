import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_event.dart';
import 'game_state.dart';
import '../../../core/sudoku/sudoku_generator.dart';
import '../../../data/models/game_models.dart';
import '../../../core/api/api_client.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  Timer? _timer;

  GameBloc() : super(const GameState()) {
    on<NewGameEvent>(_onNewGame);
    on<SelectCellEvent>(_onSelectCell);
    on<InputNumberEvent>(_onInputNumber);
    on<ToggleNotesModeEvent>(_onToggleNotesMode);
    on<EraseCellEvent>(_onEraseCell);
    on<UseHintEvent>(_onUseHint);
    on<TimerTickEvent>(_onTimerTick);
    on<AutoFillNotesEvent>(_onAutoFillNotes);
    on<RequestAICoachEvent>(_onRequestAICoach);
    on<DismissAICoachEvent>(_onDismissAICoach);
  }

  void _onNewGame(NewGameEvent event, Emitter<GameState> emit) {
    final puzzle = SudokuGenerator.generate(event.difficulty);
    final board = List.generate(9, (row) {
      return List.generate(9, (col) {
        final val = puzzle.puzzle[row][col];
        final correctVal = puzzle.solution[row][col];
        return SudokuCell(
          row: row,
          col: col,
          value: val,
          correctValue: correctVal,
          isInitial: val != 0,
          notes: const {},
          isError: false,
        );
      });
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TimerTickEvent());
    });

    emit(GameState(
      board: board,
      difficulty: event.difficulty,
      status: GameStatus.playing,
      timeElapsed: 0,
      mistakes: 0,
      hintsUsed: 0,
      selectedRow: -1,
      selectedCol: -1,
      notesMode: false,
    ));
  }

  void _onTimerTick(TimerTickEvent event, Emitter<GameState> emit) {
    if (state.status == GameStatus.playing) {
      emit(state.copyWith(timeElapsed: state.timeElapsed + 1));
    }
  }

  void _onSelectCell(SelectCellEvent event, Emitter<GameState> emit) {
    if (state.status != GameStatus.playing) return;
    emit(state.copyWith(selectedRow: event.row, selectedCol: event.col));
  }

  void _onInputNumber(InputNumberEvent event, Emitter<GameState> emit) {
    if (state.status != GameStatus.playing ||
        state.selectedRow == -1 ||
        state.selectedCol == -1) return;

    final board = List<List<SudokuCell>>.from(state.board.map((row) => List<SudokuCell>.from(row)));
    final cell = board[state.selectedRow][state.selectedCol];

    if (cell.isInitial || (cell.value != 0 && !cell.isError)) return;

    if (state.notesMode) {
      final newNotes = Set<int>.from(cell.notes);
      if (newNotes.contains(event.number)) {
        newNotes.remove(event.number);
      } else {
        newNotes.add(event.number);
      }
      board[state.selectedRow][state.selectedCol] = cell.copyWith(notes: newNotes, value: 0, isError: false);
      emit(state.copyWith(board: board));
    } else {
      bool isError = event.number != cell.correctValue;
      int newMistakes = state.mistakes;
      if (isError) {
        newMistakes++;
      } else {
        _clearNotes(board, state.selectedRow, state.selectedCol, event.number);
      }

      board[state.selectedRow][state.selectedCol] = cell.copyWith(
        value: event.number,
        isError: isError,
        notes: const {},
      );

      bool won = _checkWin(board);
      if (won) {
        _timer?.cancel();
        _saveGameToBackend(
          difficulty: state.difficulty.name,
          result: 'win',
          timeElapsed: state.timeElapsed,
          mistakes: newMistakes,
          hintsUsed: state.hintsUsed,
        );
      } else if (newMistakes >= 3) {
        _timer?.cancel();
        _saveGameToBackend(
          difficulty: state.difficulty.name,
          result: 'lose',
          timeElapsed: state.timeElapsed,
          mistakes: newMistakes,
          hintsUsed: state.hintsUsed,
        );
      }

      emit(state.copyWith(
        board: board,
        mistakes: newMistakes,
        status: won ? GameStatus.won : (newMistakes >= 3 ? GameStatus.lost : state.status),
      ));
    }
  }

  void _clearNotes(List<List<SudokuCell>> board, int r, int c, int val) {
    for (int i = 0; i < 9; i++) {
      if (board[r][i].notes.contains(val)) {
        final newNotes = Set<int>.from(board[r][i].notes)..remove(val);
        board[r][i] = board[r][i].copyWith(notes: newNotes);
      }
      if (board[i][c].notes.contains(val)) {
        final newNotes = Set<int>.from(board[i][c].notes)..remove(val);
        board[i][c] = board[i][c].copyWith(notes: newNotes);
      }
    }
    int startRow = r - r % 3;
    int startCol = c - c % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i + startRow][j + startCol].notes.contains(val)) {
          final newNotes = Set<int>.from(board[i + startRow][j + startCol].notes)..remove(val);
          board[i + startRow][j + startCol] = board[i + startRow][j + startCol].copyWith(notes: newNotes);
        }
      }
    }
  }

  void _onToggleNotesMode(ToggleNotesModeEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(notesMode: !state.notesMode));
  }

  void _onEraseCell(EraseCellEvent event, Emitter<GameState> emit) {
    if (state.status != GameStatus.playing ||
        state.selectedRow == -1 ||
        state.selectedCol == -1) return;

    final board = List<List<SudokuCell>>.from(state.board.map((row) => List<SudokuCell>.from(row)));
    final cell = board[state.selectedRow][state.selectedCol];

    if (cell.isInitial || (cell.value != 0 && !cell.isError)) return;

    board[state.selectedRow][state.selectedCol] = cell.copyWith(value: 0, notes: const {}, isError: false);
    emit(state.copyWith(board: board));
  }

  void _onUseHint(UseHintEvent event, Emitter<GameState> emit) {
    if (state.status != GameStatus.playing ||
        state.selectedRow == -1 ||
        state.selectedCol == -1) return;

    final board = List<List<SudokuCell>>.from(state.board.map((row) => List<SudokuCell>.from(row)));
    final cell = board[state.selectedRow][state.selectedCol];

    if (cell.isInitial || (cell.value == cell.correctValue && !cell.isError)) return;

    board[state.selectedRow][state.selectedCol] = cell.copyWith(
      value: cell.correctValue,
      isError: false,
      notes: const {},
    );
    
    _clearNotes(board, state.selectedRow, state.selectedCol, cell.correctValue);
    
    bool won = _checkWin(board);
    if (won) {
      _timer?.cancel();
    }

    emit(state.copyWith(
      board: board,
      hintsUsed: state.hintsUsed + 1,
      status: won ? GameStatus.won : state.status,
    ));
  }

  void _onAutoFillNotes(AutoFillNotesEvent event, Emitter<GameState> emit) {
    if (state.status != GameStatus.playing) return;

    final board = List<List<SudokuCell>>.from(state.board.map((row) => List<SudokuCell>.from(row)));
    
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c].value == 0) {
          Set<int> possible = {1, 2, 3, 4, 5, 6, 7, 8, 9};
          // Check row
          for (int i = 0; i < 9; i++) {
            if (board[r][i].value != 0 && !board[r][i].isError) {
              possible.remove(board[r][i].value);
            }
          }
          // Check col
          for (int i = 0; i < 9; i++) {
            if (board[i][c].value != 0 && !board[i][c].isError) {
              possible.remove(board[i][c].value);
            }
          }
          // Check box
          int startRow = r - r % 3;
          int startCol = c - c % 3;
          for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
              if (board[i + startRow][j + startCol].value != 0 && !board[i + startRow][j + startCol].isError) {
                possible.remove(board[i + startRow][j + startCol].value);
              }
            }
          }
          board[r][c] = board[r][c].copyWith(notes: possible);
        }
      }
    }
    emit(state.copyWith(board: board));
  }

  bool _checkWin(List<List<SudokuCell>> board) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c].value != board[r][c].correctValue) {
          return false;
        }
      }
    }
    return true;
  }

  void _onRequestAICoach(RequestAICoachEvent event, Emitter<GameState> emit) {
    if (state.status != GameStatus.playing) return;
    
    final board = state.board;

    Set<int> getPossibleValues(int r, int c) {
      Set<int> possible = {1, 2, 3, 4, 5, 6, 7, 8, 9};
      for (int i = 0; i < 9; i++) {
        if (board[r][i].value != 0 && !board[r][i].isError) possible.remove(board[r][i].value);
        if (board[i][c].value != 0 && !board[i][c].isError) possible.remove(board[i][c].value);
      }
      int startRow = r - r % 3;
      int startCol = c - c % 3;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i + startRow][j + startCol].value != 0 && !board[i + startRow][j + startCol].isError) {
            possible.remove(board[i + startRow][j + startCol].value);
          }
        }
      }
      return possible;
    }

    // 1. Check for Naked Single
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c].value == 0) {
          final possible = getPossibleValues(r, c);
          if (possible.length == 1) {
            final val = possible.first;
            emit(state.copyWith(
              selectedRow: r,
              selectedCol: c,
              aiCoachTargetRow: r,
              aiCoachTargetCol: c,
              aiCoachMessage: 'Посмотрите на выделенную ячейку (строка ${r + 1}, столбец ${c + 1}). '
                  'Методом исключения по строке, столбцу и квадрату, здесь возможна только одна цифра: $val. '
                  'Эта стратегия называется "Очевидная одиночка" (Naked Single).',
            ));
            return;
          }
        }
      }
    }

    // 2. Fallback
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c].value == 0) {
          final correctVal = board[r][c].correctValue;
          emit(state.copyWith(
            selectedRow: r,
            selectedCol: c,
            aiCoachTargetRow: r,
            aiCoachTargetCol: c,
            aiCoachMessage: 'Посмотрите на выделенную ячейку (строка ${r + 1}, столбец ${c + 1}). '
                'Если внимательно изучить блокирующие цифры в этой зоне, вы поймете, что сюда нужно поставить $correctVal.',
          ));
          return;
        }
      }
    }
  }

  void _onDismissAICoach(DismissAICoachEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(clearAICoach: true));
  }

  Future<void> _saveGameToBackend({
    required String difficulty,
    required String result,
    required int timeElapsed,
    required int mistakes,
    required int hintsUsed,
  }) async {
    try {
      await ApiClient().saveGame(
        difficulty: difficulty,
        result: result,
        timeElapsed: timeElapsed,
        mistakes: mistakes,
        hintsUsed: hintsUsed,
        isAiCoach: state.difficulty == Difficulty.easy && state.aiCoachMessage != null, // simplified heuristic
      );
    } catch (e) {
      // Ignore network errors during save for now
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
