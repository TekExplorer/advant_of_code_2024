import 'dart:async';

import 'package:advent_of_code_2024/advent_of_code_2024.dart';

Future<void> main() => Solution().solve();

class Solution extends $Solution {
  String get(int x, int y) {
    try {
      return lines[x][y];
    } catch (e) {
      return '';
    }
  }

  int checkXMASForPos(int x, int y) {
    // Dont operate unnecessarily
    if (lines[x][y] != 'X') return 0;

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

    for (var d in const [1, 2, 3]) {
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
      if (string case 'MAS') count++;
    }

    return count;
  }

  @override
  part1() {
    int count = 0;
    for (var x = 0; x < lines.length; x++) {
      for (var y = 0; y < lines[x].length; y++) {
        count += checkXMASForPos(x, y);
      }
    }

    return count.toString();
  }

  int checkCrossMASForPos(int x, int y) {
    if (lines[x][y] != 'A') return 0;

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
    int count = 0;
    for (var x = 0; x < lines.length; x++) {
      for (var y = 0; y < lines[x].length; y++) {
        count += checkCrossMASForPos(x, y);
      }
    }

    return count.toString();
  }
}
