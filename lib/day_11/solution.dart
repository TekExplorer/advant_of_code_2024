import 'dart:async';

import 'package:advent_of_code_2024/advent_of_code_2024_v2.dart';

Future<void> main() => Solution().solveActual();

// Future<void> main() => Solution().solveExample();
// Future<void> main() => Solution().solveActual();
extension on int {
  (int left, int right)? get halfOrNull {
    final str = toString();
    final len = str.length;
    if (!len.isEven) return null;
    final halfLen = len ~/ 2;
    final left = str.substring(0, halfLen).also(int.parse);
    final right = str.substring(halfLen).also(int.parse);
    return (left, right);
  }
}

class Solution extends $Solution {
  @override
  get example => Example(part1: 55312, part2: 0, '125 17');

// If the stone is engraved with the number 0, it is replaced by a stone engraved with the number 1.
// If the stone is engraved with a number that has an even number of digits, it is replaced by two stones. The left half of the digits are engraved on the new left stone, and the right half of the digits are engraved on the new right stone. (The new numbers don't keep extra leading zeroes: 1000 would become stones 10 and 0.)
// If none of the other rules apply, the stone is replaced by a new stone; the old stone's number multiplied by 2024 is engraved on the new stone.

  Iterable<int> blink(Iterable<int> list) sync* {
    for (final stone in list) {
      switch (stone) {
        case 0:
          yield 1;
          break;
        case int(halfOrNull: (final left, final right)):
          yield left;
          yield right;
          break;
        default:
          yield stone * 2024;
          break;
      }
    }
  }

  Iterable<int> blinksFor(Iterable<int> stones, [int blinks = 1]) {
    // print('starting with ${(stones)}');
    for (var i = 0; i < blinks; i++) {
      // print('i$i ${(stones)}');
      stones = blink(stones);
    }
    // print('i$blinks ${(stones)}');
    return stones;
  }

  @override
  part1(Input input) {
    final stones = input.content.split(' ').map(int.parse);
    return blinksFor(stones, 25).length;
  }

  int rockCountForBlinks(Iterable<int> stones, [int blinks = 1]) {
    var result = 0;
    for (final stone in stones) {
      recursivelyBlink(
        stone,
        addStone: (resultingStone) => result++,
        desiredDepth: blinks,
      );
    }
    return result;
  }

  final calculationCache = <int, (int, int?)>{};

  void recursivelyBlink(
    int stone, {
    required void Function(int stone) addStone,
    required int desiredDepth,
    int depth = 0,
  }) {
    if (depth == desiredDepth) {
      return addStone(stone);
    }
    void deeper(int stone) {
      recursivelyBlink(
        stone,
        addStone: addStone,
        desiredDepth: desiredDepth,
        depth: depth + 1,
      );
    }

    final (value, value2) = calculationCache.putIfAbsent(stone, () {
      // surprisingly limited number of numbers...
      print('putting for $stone');
      return switch (stone) {
        0 => (1, null),
        int(halfOrNull: (final left, final right)) => (left, right),
        _ => (stone * 2024, null),
      };
    });
    deeper(value);
    if (value2 != null) deeper(value2);
  }

  // TODO: INCOMPLETE
  @override
  part2(Input input) {
    final stones = input.content.split(' ').map(int.parse);
    return rockCountForBlinks(stones, 75);
  }
}
