import 'dart:async';

import 'package:advent_of_code_2024/advent_of_code_2024.dart';

Future<void> main() => Solution().solve();

class Solution extends $Solution {
  int checkXMASForPos(List<String> grid, int x, int y) {
    // Dont operate unnecessarily
    if (grid[x][y] != 'X') return 0;

    // just... make a list of all the possible
    // combinations based off of this position
    final horizRight = <String>[];
    final horizLeft = <String>[];
    final vertDown = <String>[];
    final vertUp = <String>[];
    final diagUpRight = <String>[];
    final diagUpLeft = <String>[];
    final diagDownRight = <String>[];
    final diagDownLeft = <String>[];

    String get(int x, int y) {
      try {
        return grid[x][y];
      } catch (e) {
        return '';
      }
    }

    for (var d in const [0, 1, 2, 3]) {
      horizRight.add(get(x + d, y));
      horizLeft.add(get(x - d, y));
      vertDown.add(get(x, y - d));
      vertUp.add(get(x, y + d));
      diagUpRight.add(get(x + d, y + d));
      diagUpLeft.add(get(x - d, y + d));
      diagDownRight.add(get(x + d, y - d));
      diagDownLeft.add(get(x - d, y - d));
    }

    final strings = [
      horizRight,
      horizLeft,
      vertDown,
      vertUp,
      diagUpRight,
      diagUpLeft,
      diagDownRight,
      diagDownLeft,
    ].map((e) => e.join());

    int count = 0;

    for (final string in strings) {
      if (string case 'XMAS') count++;
    }

    return count;
  }

  @override
  part1() {
    final grid = input.readAsLinesSync();

    int count = 0;
    for (var x = 0; x < grid.length; x++) {
      for (var y = 0; y < grid[x].length; y++) {
        count += checkXMASForPos(grid, x, y);
      }
    }

    return count.toString();
  }

  int checkCrossMASForPos(List<String> grid, int x, int y) {
    if (grid[x][y] != 'A') return 0;
    String get(int x, int y) {
      try {
        return grid[x][y];
      } catch (e) {
        return '';
      }
    }

    int count = 0;
    if ([get(x - 1, y - 1), 'A', get(x + 1, y + 1)].join()
        case 'MAS' || 'SAM') {
      if ([get(x - 1, y + 1), 'A', get(x + 1, y - 1)].join()
          case 'MAS' || 'SAM') {
        count++;
      }
    }
    return count;
  }

  @override
  part2() {
    final grid = input.readAsLinesSync();

    int count = 0;
    for (var x = 0; x < grid.length; x++) {
      for (var y = 0; y < grid[x].length; y++) {
        count += checkCrossMASForPos(grid, x, y);
      }
    }

    return count.toString();
  }
}
