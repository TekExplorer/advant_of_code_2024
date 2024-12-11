// ignore: unused_import
import 'dart:async';
import 'dart:collection';

import 'package:advent_of_code_2024/advent_of_code_2024_v2.dart';
import 'package:collection/collection.dart';

// Future<void> main() => Solution().solveActual();

Future<void> main() async {
  return Solution().solveActual();
}

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

  // TODO: INCOMPLETE
  @override
  part2(Input input) {
    final stones = input.content.split(' ').map(int.parse);
    final occurrences = stones.toOccurrenceMap(); //..display();

    // final res = blinks2For(occurrences, 6)..display();
    final res = blinks2For(occurrences, 75); //..display();

    // const expected =
    //     '2097446912 14168 4048 2 0 2 4 40 48 2024 40 48 80 96 2 8 6 7 6 0 3 2';
    // final expectedStones = expected.split(' ').map(int.parse).toList()..sort();
    // final expectedMap = expectedStones.toOccurrenceMap()..display();
    // assert(res.lock == expectedMap.lock);

    // final resList = res.toExpandedList()..sort();

    // print(resList);
    // print(expectedStones);
    // assert(resList.lock == expectedStones.lock);
    return res.values.sum;
  }

  Map<int, int> _blink2(Map<int, int> occurrences) {
    final map = <int, int /*amount*/ >{};
    void put(int stone, int mult) {
      map[stone] = (map[stone] ?? 0) + mult;
    }

    for (final MapEntry(key: stone, value: mult) in occurrences.entries) {
      switch (stone) {
        case 0:
          put(1, mult);
        case int(halfOrNull: (final left, final right)):
          put(left, mult);
          put(right, mult);
        default:
          put(stone * 2024, mult);
      }
    }

    return map;
  }

  Map<int, int> blinks2For(Map<int, int> occurrences, [int blinks = 1]) {
    // print('starting with $occurrences');
    for (var i = 0; i < blinks; i++) {
      // print('i$i $occurrences');
      occurrences = _blink2(occurrences);
    }
    // print('i$blinks $occurrences');
    return occurrences;
  }
}

extension on Iterable<int> {
  HashMap<int, int> toOccurrenceMap() {
    final occurrences = HashMap<int, int>();
    for (final stone in this) {
      occurrences[stone] = (occurrences[stone] ?? 0) + 1;
    }
    return occurrences;
  }
}

extension on Map<int, int> {
  List<int> toExpandedList() {
    final list = <int>[];
    for (final entry in entries) {
      for (final _ in Iterable.generate(entry.value)) {
        list.add(entry.key);
      }
    }
    return list;
  }

  void display() {
    print(toExpandedList().join(' '));
  }
}

final calculationCache = HashMap<int, (int, int?)>();

(int, int?) calculateStone(int stone) =>
    calculationCache.putIfAbsent(stone, () {
      // surprisingly limited number of numbers...
      // print('putting for $stone');
      return switch (stone) {
        0 => (1, null),
        int(halfOrNull: (final left, final right)) => (left, right),
        _ => (stone * 2024, null),
      };
    });
