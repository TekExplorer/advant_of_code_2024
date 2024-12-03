import 'dart:async';

import 'package:advent_of_code_2024/advent_of_code_2024.dart';
import 'package:collection/collection.dart';

Future<void> main() => Solution().solve();

class Solution extends $Solution {
  // regex for exactly mul(int, int)
  static final regex = RegExp(r'mul\((\d+),(\d+)\)');
  @override
  part1() {
    final matches = regex.allMatches(input.readAsStringSync());
    final array = matches
        .map((e) => e.groups(const [1, 2]))
        .map((e) => (int.parse(e[0]!), int.parse(e[1]!)))
        .map((e) => e.$1 * e.$2);

    return array.sum.toString();
  }

  @override
  part2() {
    final contents = input.readAsStringSync();

    final byDont = contents.split("don't()");

    final firstSection = byDont.removeAt(0);
    byDont.removeWhere((e) => !e.contains('do()'));

    final safeSections = [firstSection];
    for (final section in byDont) {
      final doIndex = section.indexOf('do()');
      safeSections.add(section.substring(doIndex));
    }

    int result = 0;
    for (final section in safeSections) {
      final matches = regex.allMatches(section);
      final array = matches
          .map((e) => e.groups(const [1, 2]))
          .map((e) => (int.parse(e[0]!), int.parse(e[1]!)))
          .map((e) => e.$1 * e.$2);

      result += array.sum;
    }

    return result.toString();
  }
}
