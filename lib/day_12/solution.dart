import 'dart:async';
import 'dart:collection';

import 'package:advent_of_code_2024/advent_of_code_2024_v2.dart';
import 'package:advent_of_code_2024/direction.dart';
import 'package:collection/collection.dart';

import '../grid.dart';

// Future<void> main() => Solution().solve();
Future<void> main() => Solution().solveExample();
// Future<void> main() => Solution().solveActual();

class Solution extends $Solution {
  @override
  get example => Example(part1: 1930, part2: 1206, '''
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
''');

  List<Group> process(Grid grid) {
    final groups = <Group>[];
    for (final pos in grid.positions) {
      final value = grid[pos];

      final validGroups = <Group>[];
      final nearby = Direction.values.map((e) => e.modify(pos));
      for (final g in groups.where((group) => group.value == value)) {
        if (g.positions.any(nearby.contains)) {
          validGroups.add(g);
        }
      }
      final group = switch (validGroups) {
        List(length: 0) => Group(value, grid)..also(groups.add),
        List(length: 1) => validGroups.single,
        _ => validGroups.merge()..also(groups.add),
      };

      group.positions.add(pos);
      groups.removeWhere((g) => g.positions.isEmpty);
    }
    return groups;
  }

  @override
  part1(Input input) {
    final groups = process(input.grid);
    return groups.map((e) => e.priceByPerimeter).sum;
  }

  @override
  part2(Input input) {
    final groups = process(input.grid);
    for (var group in groups) {
      print(group.toStringSides());
    }
    return groups.map((e) => e.priceBySides).sum;
  }
}

class Group {
  Group(this.value, this.grid);
  final Grid grid;
  final Char value;
  final positions = HashSet<XY>();

  int get area => positions.length;

  @override
  String toString() => toStringPerimeter();

  String toStringPerimeter() =>
      'A region of $value with price $area * $perimeter = $priceByPerimeter';

  String toStringSides() =>
      'A region of $value with price $area * $sides = $priceBySides';
}

extension Perimeter on Group {
  int get perimeter {
    int count = 0;
    for (final pos in positions) {
      for (final d in Direction.values) {
        final at = d.modify(pos);
        final valueAt = grid[at];
        if (valueAt != value) count++;
      }
    }
    return count;
  }

  int get sides => _countSides();
}

extension Price on Group {
  int get priceByPerimeter => perimeter * area;
  int get priceBySides => sides * area;
}

extension on Iterable<Group> {
  Group merge() {
    final g = Group(first.value, first.grid);
    for (final group in this) {
      g.positions.addAll(group.positions);
      group.positions.clear();
    }
    return g;
  }
}

extension on Group {
  Iterable<(XY, Direction)> get _edges sync* {
    for (final pos in positions) {
      for (final direction in Direction.values) {
        if (!positions.contains(direction.modify(pos))) {
          // if the point ahead isn't part of the group...
          yield (pos, direction);
        }
      }
    }
  }

  HashMap<Direction, Set<XY>> get _edgesMap {
    final map = HashMap<Direction, Set<XY>>();
    for (final (pos, direction) in _edges) {
      (map[direction] ??= HashSet()).add(pos);
    }
    return map;
  }

  // TODO: failing
  int _countSides() {
    int count = 0;
    for (final (direction, points) in _edgesMap.kv) {
      final map = HashMap<int, Set<int>>();
      for (final point in points) {
        switch (direction) {
          case Direction.left || Direction.right:
            (map[point.y] ??= HashSet()).add(point.x);
          case Direction.up || Direction.down:
            (map[point.x] ??= HashSet()).add(point.y);
        }
      }
      //
      for (final set in map.values) {
        final sorted = set.toSortedList();
        int previous = sorted.first;
        count++;
        for (final v in sorted) {
          if ((previous + 1) == v) {
            // good. part of the same line
          } else {
            count++;
          }
          previous = v;
        }
      }
    }
    return count;
  }
}
