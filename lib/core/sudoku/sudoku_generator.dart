import 'dart:math';

enum Difficulty { easy, medium, hard, expert }

class SudokuPuzzle {
  final List<List<int>> puzzle;
  final List<List<int>> solution;

  SudokuPuzzle(this.puzzle, this.solution);
}

class SudokuGenerator {
  static final _random = Random();

  /// Generates a unique Sudoku puzzle for the given difficulty
  static SudokuPuzzle generate(Difficulty difficulty) {
    List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid);
    List<List<int>> solution = List.generate(9, (i) => List.from(grid[i]));
    
    int cellsToRemove;
    switch (difficulty) {
      case Difficulty.easy:
        cellsToRemove = 30; // 51 remaining
        break;
      case Difficulty.medium:
        cellsToRemove = 45; // 36 remaining
        break;
      case Difficulty.hard:
        cellsToRemove = 55; // 26 remaining
        break;
      case Difficulty.expert:
        cellsToRemove = 64; // 17 remaining (minimum for unique in general, but hard to generate quickly)
        break;
    }
    
    // Fallback: If we can't find a unique solution quickly, we just remove as many as we safely can.
    _removeCellsUnique(grid, cellsToRemove);
    return SudokuPuzzle(grid, solution);
  }

  static bool _fillGrid(List<List<int>> grid) {
    for (int i = 0; i < 81; i++) {
      int row = i ~/ 9;
      int col = i % 9;
      if (grid[row][col] == 0) {
        List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle(_random);
        for (int num in numbers) {
          if (_isValid(grid, row, col, num)) {
            grid[row][col] = num;
            if (_fillGrid(grid)) {
              return true;
            }
            grid[row][col] = 0;
          }
        }
        return false;
      }
    }
    return true;
  }

  static bool _isValid(List<List<int>> grid, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] == num) return false;
      if (grid[i][col] == num) return false;
    }
    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[i + startRow][j + startCol] == num) return false;
      }
    }
    return true;
  }

  /// Removes cells while ensuring the puzzle still has exactly one solution.
  static void _removeCellsUnique(List<List<int>> grid, int targetRemove) {
    List<int> cells = List.generate(81, (i) => i)..shuffle(_random);
    int removed = 0;
    
    for (int cell in cells) {
      if (removed >= targetRemove) break;
      
      int row = cell ~/ 9;
      int col = cell % 9;
      
      if (grid[row][col] != 0) {
        int backup = grid[row][col];
        grid[row][col] = 0;
        
        // Count solutions
        int solutions = _countSolutions(grid);
        
        if (solutions != 1) {
          // If not unique, revert
          grid[row][col] = backup;
        } else {
          removed++;
        }
      }
    }
  }

  static int _countSolutions(List<List<int>> grid) {
    int count = 0;
    
    bool solve(int pos) {
      if (pos == 81) {
        count++;
        return count > 1; // Stop early if more than 1 solution
      }
      
      int row = pos ~/ 9;
      int col = pos % 9;
      
      if (grid[row][col] != 0) {
        return solve(pos + 1);
      }
      
      for (int num = 1; num <= 9; num++) {
        if (_isValid(grid, row, col, num)) {
          grid[row][col] = num;
          if (solve(pos + 1)) return true; // Stop early
          grid[row][col] = 0;
        }
      }
      return false;
    }
    
    solve(0);
    return count;
  }
}
