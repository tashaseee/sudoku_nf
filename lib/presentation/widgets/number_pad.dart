import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        // Count frequencies of numbers on the board
        Map<int, int> frequencies = {};
        if (state.board.isNotEmpty) {
          for (var row in state.board) {
            for (var cell in row) {
              if (cell.value != 0 && !cell.isError) {
                frequencies[cell.value] = (frequencies[cell.value] ?? 0) + 1;
              }
            }
          }
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildActionBtn(
                    context,
                    icon: Icons.undo,
                    label: 'Отмена',
                    onTap: () {
                      // Implement undo logic later
                    },
                  ),
                ),
                Expanded(
                  child: _buildActionBtn(
                    context,
                    icon: Icons.backspace_outlined,
                    label: 'Ластик',
                    onTap: () => context.read<GameBloc>().add(EraseCellEvent()),
                  ),
                ),
                Expanded(
                  child: _buildActionBtn(
                    context,
                    icon: state.notesMode ? Icons.edit : Icons.edit_outlined,
                    label: 'Заметки',
                    isActive: state.notesMode,
                    onTap: () => context.read<GameBloc>().add(ToggleNotesModeEvent()),
                  ),
                ),
                Expanded(
                  child: _buildActionBtn(
                    context,
                    icon: Icons.lightbulb_outline,
                    label: 'Подсказка',
                    onTap: () => context.read<GameBloc>().add(UseHintEvent()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 0.85,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                int number = index + 1;
                bool isCompleted = (frequencies[number] ?? 0) == 9;

                return InkWell(
                  onTap: isCompleted ? null : () => context.read<GameBloc>().add(InputNumberEvent(number)),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.5,
                      ),
                      boxShadow: isCompleted ? [] : [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(4, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.05), // Fake light source
                          blurRadius: 8,
                          offset: const Offset(-4, -4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        number.toString(),
                        style: TextStyle(
                          fontSize: 32,
                          color: isCompleted 
                              ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)
                              : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ).animate().scale(delay: (50 * index).ms, duration: 300.ms, curve: Curves.easeOutBack);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(3, 3),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(-3, -3),
                  )
                ],
              ),
              child: Icon(
                icon,
                color: isActive
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    ).animate().fade().slideY(begin: 0.5);
  }
}
