import 'dart:async';

import 'package:advent_of_code_2024/advent_of_code_2024_v2.dart';
import 'package:advent_of_code_2024/direction.dart';
import 'package:advent_of_code_2024/grid.dart';

// Future<void> main() => Solution().solve();
Future<void> main() => Solution().solveExample();
// Future<void> main() => Solution().solveActual();
var shouldDisplay = true;

class Solution extends $Solution {
  get example1 => Example(part1: 7036, part2: 0, '''
###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############
''');

  get example2 => Example(part1: 11048, part2: 0, '''
#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################
''');

  @override
  get example => example2;

  @override
  part1(Input input) {
    final puzzle = input.puzzle();
    return puzzle.cheapestPath.cost;
  }

  @override
  part2(Input input) => 0;
}

const forwardCost = 1;
const turnCost = 1000;
// east
// const startingFacing = Direction.right;
// find the lowest score

extension on Input {
  _Part1Grid puzzle() => _Part1Grid(grid);
}

typedef Path = ({ISet<XY> visited, IList<Action> actions});

extension on Iterable<Action> {
  int get cost {
    var cost = 0;
    for (final action in this) {
      cost += action == Action.forward ? forwardCost : turnCost;
    }
    return cost;
  }
}

class _Part1Grid {
  _Part1Grid(this.grid);
  final Grid grid;
  XY get posOfStart => grid.posOf(Char('S'))!;
  XY get posOfEnd => grid.posOf(Char('E'))!;

  Iterable<Action> get cheapestPath {
    return allPossibleRoutes.map((route) {
      final actions = route.chained(start: posOfStart).actions(posOfStart);
      return actions;
    }).reduce((a, b) => a.cost < b.cost ? a : b);
  }

  void display(Iterable<Action> actions) {
    if (!shouldDisplay) return;

    final grid = this.grid.clone();

    var current = posOfStart;
    var facing = Direction.right;
    void setCur() {
      grid[current] = Char(switch (facing) {
        Direction.up => '^',
        Direction.down => 'v',
        Direction.left => '<',
        Direction.right => '>',
      });
    }

    setCur();
    for (final action in actions) {
      switch (action) {
        case Action.forward:
          current = facing.modify(current);
        case Action.turnLeft:
          facing = facing.rotated270;
        case Action.turnRight:
          facing = facing.rotated90;
      }
      setCur();
    }
    print(grid);
  }

  late final allEmptyPositions = grid.allPosOf(Char.dot).toISet();

  Iterable<ISet<XY>> get allPossibleRoutes => _calculatePossibleRoutes(
        current: posOfStart,
        visited: ISet(),
        depth: 0,
      );
  Iterable<ISet<XY>> _calculatePossibleRoutes({
    required XY current,
    required ISet<XY> visited,
    required int depth,
  }) sync* {
    final validPositions = allEmptyPositions.difference(visited);

    if (shouldDisplay) {
      final grid = this.grid.clone();
      for (final pos in visited) {
        grid[pos] = Char('+');
      }
      print(grid);
    }

    if (validPositions.isEmpty) {
      return;
    }

    for (final next in Direction.values.map((e) => e.modify(current))) {
      if (next == posOfEnd) {
        var path = visited.add(current).add(next);
        if (shouldDisplay) {
          display(path.chained(start: posOfStart).actions(posOfStart));
          print(
              'Cost: ${path.chained(start: posOfStart).actions(posOfStart).cost}');
          print('Cost: ${path.actions(posOfStart).cost}');
        }
        yield path;
        continue;
      }
      if (!validPositions.contains(next)) continue;
      yield* _calculatePossibleRoutes(
        current: next,
        visited: visited.add(current),
        depth: depth + 1,
      );
    }
  }
}

extension on Iterable<XY> {
  Iterable<Action> actions(XY start) sync* {
    var current = start;
    var facing = Direction.right;
    for (final next in this) {
      if (!current.isAdjacentTo(next) && current != start) {
        throw StateError('Not a neighbor. consider sorting?');
      }
      final direction = current.directionToAdjacentPos(next);
      if (direction == facing) {
        yield Action.forward;
      } else {
        if (facing.rotated90 == direction) {
          yield Action.turnRight;
        } else if (facing.rotated270 == direction) {
          yield Action.turnLeft;
        } else {
          throw StateError('Invalid direction');
        }
        yield Action.forward;
      }
    }
  }

  Iterable<XY> chained({required XY start}) sync* {
    if (!contains(start)) throw ArgumentError('Start not in list');

    var list = toIList().remove(start);
    var current = start;
    yield current;
    while (list.isNotEmpty) {
      final next = list.firstWhere((e) => current.isNeighborTo(e), orElse: () {
        throw StateError(
          'No neighbor found. Is not connected.'
          ' Current: $current Remaining: $list',
        );
      });
      yield current;
      current = next;
      list = list.remove(current);
    }
  }
}

extension on XY {
  bool isAdjacentTo(XY other) => (x - other.x).abs() + (y - other.y).abs() == 1;
  bool isDiagonalTo(XY other) =>
      (x - other.x).abs() == 1 && (y - other.y).abs() == 1;

  bool isNeighborTo(XY other) => isAdjacentTo(other) || isDiagonalTo(other);

  Direction directionToAdjacentPos(XY other) {
    if (x == other.x) {
      return y < other.y ? Direction.down : Direction.up;
    } else if (y == other.y) {
      return x < other.x ? Direction.right : Direction.left;
    } else {
      throw ArgumentError('Not a neighbor');
    }
  }
}

enum Action {
  forward,
  turnLeft,
  turnRight;

  bool get isTurn => this == Action.turnLeft || this == Action.turnRight;
}
