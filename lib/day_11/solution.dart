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
  // idk if this can be optimized...
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

  @override
  part1(Input input) {
    final stones = input.content.split(' ').map(int.parse);
    return blinksFor(stones.toOccurrenceMap(), 25).values.sum;
  }

  @override
  part2(Input input) {
    final stones = input.content.split(' ').map(int.parse);
    return blinksFor(stones.toOccurrenceMap(), 75).values.sum;
  }

  final _ruleApplicatorCache = HashMap<int, (int, int?)>();
  (int, int?) applyRulesOnStone(int stone) =>
      _ruleApplicatorCache.putIfAbsent(stone, () {
        return switch (stone) {
          0 => (1, null),
          int(halfOrNull: (final left, final right)) => (left, right),
          _ => (stone * 2024, null),
        };
      });

  Map<int, int> _blink(Map<int, int> occurrences) {
    final map = HashMap<int, int /*amount*/ >();
    void put(int stone, int mult) {
      map[stone] = (map[stone] ?? 0) + mult;
    }

    for (final MapEntry(key: stone, value: mult) in occurrences.entries) {
      final (l, r) = applyRulesOnStone(stone);
      put(l, mult);
      if (r != null) put(r, mult);
    }

    return map;
  }

  Map<int, int> blinksFor(Map<int, int> occurrences, [int blinks = 1]) {
    for (var i = 0; i < blinks; i++) {
      occurrences = _blink(occurrences);
    }
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
