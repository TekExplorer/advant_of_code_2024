import 'dart:async';

import 'package:advent_of_code_2024/advent_of_code_2024.dart';
import 'package:collection/collection.dart';

Future<void> main() => Solution().solve();

class Solution extends $Solution {
  // regex for exactly mul(int, int)
  static final regex = RegExp(r'mul\((\d+),(\d+)\)');
  @override
  part1() {
    final matches = regex.allMatches(contents);

    final array = matches
        .map((e) => e.groups(const [1, 2]).nonNulls.map(int.parse))
        .map((e) => e.first * e.last);

    return array.sum;
  }

  @override
  part2() {
    final [firstSection, ...byDont] = contents.split("don't()");

    final safeSections = [firstSection];

    for (final section in byDont) {
      final doIndex = section.indexOf('do()');
      if (doIndex != -1) safeSections.add(section.substring(doIndex));
    }

    int result = 0;
    for (final section in safeSections) {
      final matches = regex.allMatches(section);

      final array = matches
          .map((e) => e.groups(const [1, 2]).nonNulls.map(int.parse))
          .map((e) => e.first * e.last);

      result += array.sum;
    }

    return result;
  }
}
