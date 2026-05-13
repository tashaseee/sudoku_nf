import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import '../../data/models/game_models.dart';

class SudokuBoard extends StatelessWidget {
  const SudokuBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state.board.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFDD233B)));
        }

        return AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9,
                ),
                itemCount: 81,
                itemBuilder: (context, index) {
                  int row = index ~/ 9;
                  int col = index % 9;
                  return _buildCell(context, state, row, col);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(BuildContext context, GameState state, int row, int col) {
    final cell = state.board[row][col];
    final isSelected = state.selectedRow == row && state.selectedCol == col;
    final isRelated = !isSelected &&
        (state.selectedRow == row ||
            state.selectedCol == col ||
            (state.selectedRow ~/ 3 == row ~/ 3 &&
                state.selectedCol ~/ 3 == col ~/ 3));
    final isSameValue = state.selectedRow != -1 &&
        state.selectedCol != -1 &&
        state.board[state.selectedRow][state.selectedCol].value != 0 &&
        state.board[state.selectedRow][state.selectedCol].value == cell.value &&
        cell.value != 0;

    final isAITarget = state.aiCoachTargetRow == row && state.aiCoachTargetCol == col;

    // Color logic
    Color bgColor;
    if (isAITarget) {
      bgColor = Colors.amber.withOpacity(0.35);
    } else if (cell.isError && cell.value != 0) {
      bgColor = const Color(0xFFDD233B).withOpacity(0.12);
    } else if (isSelected) {
      bgColor = const Color(0xFFDD233B).withOpacity(0.15);
    } else if (isSameValue) {
      bgColor = const Color(0xFFDD233B).withOpacity(0.07);
    } else if (isRelated) {
      bgColor = const Color(0xFFF3F4F6);
    } else {
      // Alternating 3x3 blocks subtle tint
      final isAltBlock = ((row ~/ 3) + (col ~/ 3)) % 2 == 1;
      bgColor = isAltBlock ? const Color(0xFFF9FAFB) : Colors.white;
    }

    // Border widths
    final topW = (row > 0 && row % 3 == 0) ? 2.0 : 0.5;
    final leftW = (col > 0 && col % 3 == 0) ? 2.0 : 0.5;
    final rightW = (col < 8 && (col + 1) % 3 == 0) ? 2.0 : 0.5;
    final bottomW = (row < 8 && (row + 1) % 3 == 0) ? 2.0 : 0.5;

    const blockBorderColor = Color(0xFF94A3B8);
    const thinBorderColor = Color(0xFFE2E8F0);

    Widget cellWidget = GestureDetector(
      onTap: () => context.read<GameBloc>().add(SelectCellEvent(row, col)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: BorderSide(color: topW > 1 ? blockBorderColor : thinBorderColor, width: topW),
            left: BorderSide(color: leftW > 1 ? blockBorderColor : thinBorderColor, width: leftW),
            right: BorderSide(color: rightW > 1 ? blockBorderColor : thinBorderColor, width: rightW),
            bottom: BorderSide(color: bottomW > 1 ? blockBorderColor : thinBorderColor, width: bottomW),
          ),
        ),
        child: Center(
          child: _buildCellContent(context, cell, isSelected),
        ),
      ),
    );

    // Pulse animation for AI target
    if (isAITarget) {
      cellWidget = cellWidget
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1.0, end: 1.04, duration: 500.ms, curve: Curves.easeInOut);
    }

    return cellWidget;
  }

  Widget _buildCellContent(BuildContext context, SudokuCell cell, bool isSelected) {
    if (cell.value != 0) {
      Color textColor;
      if (cell.isError) {
        textColor = const Color(0xFFDD233B);
      } else if (cell.isInitial) {
        textColor = const Color(0xFF0F172A);
      } else {
        textColor = const Color(0xFFDD233B);
      }

      return Text(
        cell.value.toString(),
        style: TextStyle(
          fontSize: 22,
          fontWeight: cell.isInitial ? FontWeight.w800 : FontWeight.w600,
          color: textColor,
          fontFamily: 'Poppins',
        ),
      ).animate(key: ValueKey('${cell.value}-${cell.isError}')).scale(duration: 150.ms, curve: Curves.easeOutBack);
    }

    if (cell.notes.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(1.5),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final num = index + 1;
            return Center(
              child: cell.notes.contains(num)
                  ? Text(
                      num.toString(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
