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

    final rules = <(int, int)>[];
    final updates = <List<int>>[];

    for (final line in lines) {
      if (line.isEmpty) continue;

      if (line.contains('|')) {
        final [left, right] = line.split('|').map(int.parse).toList();

        rules.add((left, right));
      } else {
        updates.add(line.split(',').map(int.parse).toList());
      }
    }
    final validUpdates = <List<int>>[...updates];

    for (final update in updates) {
      if (!isValid(update, rules)) {
        validUpdates.remove(update);
      }
    }

    return validUpdates.map((e) => e.middle).sum.toString();
  }

  bool isValid(Iterable<int> update, List<(int, int)> rules) {
    for (final (index, value) in update.indexed) {
      bool violated = rules
          // where this value should be left of
          .where((e) => e.$1 == value)
          // if any value that should be to the right is found, its violated
          .any((rule) => update.take(index).contains(rule.$2));
      if (violated) return false;
    }
    return true;
  }

  @override
  part2() {
    // final lines = LineSplitter().convert(contents);

    final rules = <(int, int)>[];
    final updates = <List<int>>[];

    for (final line in lines) {
      if (line.isEmpty) continue;

      if (line.contains('|')) {
        final [left, right] = line.split('|').map(int.parse).toList();

        rules.add((left, right));
      } else {
        updates.add(line.split(',').map(int.parse).toList());
      }
    }
    final validUpdates = <List<int>>[...updates];
    final invalidUpdates = <List<int>>[];

    for (final update in updates) {
      if (!isValid(update, rules)) {
        validUpdates.remove(update);
        invalidUpdates.add(update);
      }
    }

    List<int> sortUpdate(List<int> update) {
      final things = [...update];
      things.sort((value, other) {
        if (value == other) return 0;
        if (rules.contains((value, other))) return -1;
        if (rules.contains((other, value))) return 1;
        // has no rule
        return 0;
      });
      return things;
    }

    return invalidUpdates.map(sortUpdate).map((e) => e.middle).sum.toString();
  }
}

class Thing implements Comparable<Thing> {
  Thing({required this.rules, required this.value});
  final List<(int, int)> rules;
  final int value;

  @override
  int compareTo(other) {
    if (value == other.value) return 0;
    if (rules.contains((value, other.value))) return -1;
    if (rules.contains((other.value, value))) return 1;
    // has no rule
    return 0;
  }
}
