import 'dart:async';

import 'package:advent_of_code_2024/advent_of_code_2024.dart';
import 'package:collection/collection.dart';

Future<void> main() => Solution().solve();

extension on Iterable<int> {
  bool isSafe() =>
      isSafelyIncrementing() || toList().reversed.isSafelyIncrementing();

  Iterable<List<int>> splayOneMissing() sync* {
    for (var index = 0; index < length; index++) {
      yield [
        ...ListSlice(toList(), 0, index),
        ...skip(index + 1),
      ];
    }
  }

  bool isSafelyIncrementing() {
    var previous = first;
    final iterator = skip(1).iterator;

    while (iterator.moveNext()) {
      if (iterator.current <= previous || (iterator.current - previous) > 3) {
        return false;
      } else {
        previous = iterator.current;
      }
    }
    return true;
  }
}

class Solution extends $Solution {
  @override
  part1() {
    final grid = lines.map((line) => line.split(' ').map(int.parse));
    int safeCount = 0;
    for (final line in grid) {
      if (line.isSafe()) safeCount++;
    }

    return safeCount;
  }

  @override
  part2() {
    final grid = lines.map((line) => line.split(' ').map(int.parse));
    int safeCount = 0;
    for (final $line in grid) {
      for (final line in $line.splayOneMissing()) {
        if (line.isSafe()) {
          safeCount++;
          break;
        }
      }
    }

    return safeCount;
  }
}
