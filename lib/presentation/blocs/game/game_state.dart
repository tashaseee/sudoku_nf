import 'package:equatable/equatable.dart';
import '../../../data/models/game_models.dart';
import '../../../core/sudoku/sudoku_generator.dart';

enum GameStatus { initial, playing, won, lost, paused }

class GameState extends Equatable {
  final List<List<SudokuCell>> board;
  final Difficulty difficulty;
  final int selectedRow;
  final int selectedCol;
  final bool notesMode;
  final int mistakes;
  final int hintsUsed;
  final int timeElapsed; // in seconds
  final GameStatus status;
  final String? aiCoachMessage;
  final int? aiCoachTargetRow;
  final int? aiCoachTargetCol;

  const GameState({
    this.board = const [],
    this.difficulty = Difficulty.easy,
    this.selectedRow = -1,
    this.selectedCol = -1,
    this.notesMode = false,
    this.mistakes = 0,
    this.hintsUsed = 0,
    this.timeElapsed = 0,
    this.status = GameStatus.initial,
    this.aiCoachMessage,
    this.aiCoachTargetRow,
    this.aiCoachTargetCol,
  });

  GameState copyWith({
    List<List<SudokuCell>>? board,
    Difficulty? difficulty,
    int? selectedRow,
    int? selectedCol,
    bool? notesMode,
    int? mistakes,
    int? hintsUsed,
    int? timeElapsed,
    GameStatus? status,
    String? aiCoachMessage,
    int? aiCoachTargetRow,
    int? aiCoachTargetCol,
    bool clearAICoach = false,
  }) {
    return GameState(
      board: board ?? this.board,
      difficulty: difficulty ?? this.difficulty,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      notesMode: notesMode ?? this.notesMode,
      mistakes: mistakes ?? this.mistakes,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      status: status ?? this.status,
      aiCoachMessage: clearAICoach ? null : (aiCoachMessage ?? this.aiCoachMessage),
      aiCoachTargetRow: clearAICoach ? null : (aiCoachTargetRow ?? this.aiCoachTargetRow),
      aiCoachTargetCol: clearAICoach ? null : (aiCoachTargetCol ?? this.aiCoachTargetCol),
    );
  }

  @override
  List<Object?> get props => [
    board,
    difficulty,
    selectedRow,
    selectedCol,
    notesMode,
    mistakes,
    hintsUsed,
    timeElapsed,
    status,
    aiCoachMessage,
    aiCoachTargetRow,
    aiCoachTargetCol,
  ];
}
