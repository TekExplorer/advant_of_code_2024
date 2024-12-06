import 'dart:async';

import 'package:advent_of_code_2024/advent_of_code_2024.dart';
import 'package:collection/collection.dart';

Future<void> main() => Solution().solve();

extension<T> on List<T> {
  T get middle {
    assert(length.isOdd);
    var middleIndex = (length + 1) ~/ 2;
    return this[middleIndex - 1];
  }
}

typedef Update = List<int>;
typedef Rule = ({int low, int high});

class Solution extends $Solution {
  String get contents => '''47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47''';

  @override
  part1() {
    // final lines = LineSplitter().convert(contents);
    final (:rules, :updates) = getRulesUpdates(lines);

    final validUpdates = <Update>[];

    for (final update in updates) {
      if (isValid(update, rules)) validUpdates.add(update);
    }

    return validUpdates.map((e) => e.middle).sum.toString();
  }

  bool isValid(Iterable<int> update, List<Rule> rules) {
    return update.isSorted(ruleCompare(rules));
  }

  int Function(int value, int other) ruleCompare(List<Rule> rules) =>
      (int value, int other) {
        if (value == other) return 0;
        if (rules.contains((high: other, low: value))) return -1;
        if (rules.contains((low: other, high: value))) return 1;
        // has no rule
        return 0;
      };

  ({
    List<Rule> rules,
    List<Update> updates,
  }) getRulesUpdates(Iterable<String> lines) {
    final rules = <Rule>[];
    final updates = <Update>[];

    for (final line in lines) {
      if (line.isEmpty) continue;

      if (line.contains('|')) {
        final [left, right] = line.split('|').map(int.parse).toList();

        rules.add((low: left, high: right));
      } else {
        updates.add(line.split(',').map(int.parse).toList());
      }
    }
    return (rules: rules, updates: updates);
  }

  @override
  part2() {
    // final lines = LineSplitter().convert(contents);

    final (:rules, :updates) = getRulesUpdates(lines);

    final validUpdates = <Update>[];
    final invalidUpdates = <Update>[];

    for (final update in updates) {
      if (isValid(update, rules)) {
        validUpdates.add(update);
      } else {
        invalidUpdates.add(update);
      }
    }

    Update sortUpdate(Update update) {
      final things = [...update];
      things.sort(ruleCompare(rules));
      return things;
    }

    return invalidUpdates.map(sortUpdate).map((e) => e.middle).sum.toString();
  }
}
