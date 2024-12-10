import 'dart:async';
import 'dart:collection';

import 'package:advent_of_code_2024/advent_of_code_2024_v2.dart';
import 'package:advent_of_code_2024/grid.dart';
import 'package:collection/collection.dart';

Future<void> main() => Solution().solve();
// Future<void> main() => Solution().solveExample();
// Future<void> main() => Solution().solveActual();

// as long as possible
// incremental
// trail-head = 0
// score: number of branches that reach 9
class Solution extends $Solution {
  @override
  get example => Example(part1: 36, part2: 0, '''
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
''');

  Iterable<int> calculateTrailScores(Grid grid) sync* {
    for (final startingPos in grid.allPositionsOf((c) => c.char == '0')) {
      print('starting at $startingPos');
      final paths = ninesReached(startingPos, grid);
      yield paths.length;
    }
  }

  HashSet<XY> ninesReached(XY startingPos, Grid grid) {
    final paths = buildPaths(pos: startingPos, grid: grid);
    // print(
    //     'Length for starting point (${startingPos.x}, ${startingPos.y}): ${paths.length}');
    // for (final path in paths) {
    //   final buffer = StringBuffer();
    //   for (final point in path) {
    //     buffer.write('(${point.x}, ${point.y}) ${grid[point]} ');
    //   }
    //   print(buffer);
    // }
    return HashSet<XY>()..addAll(paths.map((e) => e.last));
  }

  int calculateRating(Grid grid) {
    int count = 0;
    for (final startingPos in grid.allPositionsOf((c) => c.char == '0')) {
      print('starting at $startingPos');
      final paths = buildPaths(pos: startingPos, grid: grid);
      count += paths.length;
    }
    return count;
  }

  // findReachableNines;
  // a cache would be useful
  Iterable<IList<XY>> buildPaths({
    IList<XY>? current,
    required XY pos,
    required Grid grid,
    int depth = 0,
  }) sync* {
    current ??= IList();
    // dont get caught in a loop
    if (current.contains(pos)) return;
    if (depth == 10) throw StateError('Recursion error');
    final value = grid.get(pos).toInt();
    if (value == null) {
      return;
    }
    if (current.isNotEmpty && grid.get(current.last).toInt() != value - 1) {
      // too steep
      return;
    }
    if (value == 9) {
      yield current.add(pos);
      return;
    }
    for (final direction in Direction.values) {
      yield* buildPaths(
        current: current.add(pos),
        pos: direction.modify(pos),
        grid: grid,
        depth: depth + 1,
      );
    }
  }

  @override
  part1(Input input) => calculateTrailScores(input.grid).sum;

  @override
  part2(Input input) => calculateRating(input.grid);
}

class Tree {
  final int value = 0;
  final children = <Direction, Node>{};
}

class Node implements Tree {
  Node(this.direction, this.value);
  @override
  final int value;
  final Direction direction;
  @override
  final children = <Direction, Node>{};
}

extension on Grid {
  Iterable<XY> allPositionsOf(bool Function(Char char) test) sync* {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final pos = (x: x, y: y);
        if (test(get(pos))) yield pos;
      }
    }
  }
}

enum Direction {
  up,
  down,
  left,
  right;

  XY modify(XY pos) => switch (this) {
        Direction.up => (x: pos.x, y: pos.y - 1),
        Direction.down => (x: pos.x, y: pos.y + 1),
        Direction.left => (x: pos.x - 1, y: pos.y),
        Direction.right => (x: pos.x + 1, y: pos.y),
      };
}
