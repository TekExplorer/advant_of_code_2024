import 'dart:async';

import 'package:advent_of_code_2024/advent_of_code_2024.dart';

Future<void> main() => Solution().solve();

class Solution extends $Solution {
  (List<int>, List<int>) getLists() {
    final List<int> left = [];
    final List<int> right = [];

    for (final line in lines) {
      final [l, r] = line.split(RegExp(r'\s+')).map(int.parse).toList();
      left.add(l);
      right.add(r);
    }
    return (left, right);
  }

  @override
  part1() {
    final (left, right) = getLists();

    left.sort();
    right.sort();
    int distance = 0;

    for (var i = 0; i < left.length; i++) {
      final diff = (left[i] - right[i]).abs();
      distance += diff;
    }

    return distance.toString();
  }

  @override
  part2() {
    final (left, right) = getLists();
    right.sort();

    final Map<int, int> timesFoundInRight = {};

    for (final int i in right) {
      timesFoundInRight[i] = (timesFoundInRight[i] ?? 0) + 1;
    }

    int similarityScore = 0;
    for (final int i in left) {
      similarityScore += (i * (timesFoundInRight[i] ?? 0));
    }
    return similarityScore.toString();
  }
}
