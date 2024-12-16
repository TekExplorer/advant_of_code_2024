import 'dart:async';

import 'package:advent_of_code_2024/advent_of_code_2024_v2.dart';
import 'package:advent_of_code_2024/direction.dart';
import 'package:advent_of_code_2024/grid.dart';

// Future<void> main() => Solution().solve();
// Future<void> main() => Solution().solveExample();
Future<void> main() => Solution().solveActual();
var shouldDisplay = false;

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
    return puzzle.cheapestPath.actions.cost;
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

extension on IList<Action> {
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

  Path get cheapestPath => allPossiblePaths.reduce(
        (a, b) => a.actions.cost < b.actions.cost ? a : b,
      );
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

  Iterable<Path> get allPossiblePaths {
    return _allPossiblePaths(
      posOfStart,
      ISet(),
      IList(),
      Direction.right, // east
      false,
      0,
    );
  }

  Iterable<Path> _allPossiblePaths(
    XY current,
    ISet<XY> visited,
    IList<Action> actions,
    Direction facing,
    bool didTurn,
    int depth,
  ) sync* {
    final validPositions = allEmptyPositions.difference(visited);

    if (shouldDisplay) print(actions.map((e) => e.name).join(' '));
    display(actions);

    final forward = facing.modify(current);
    if (forward == posOfEnd) {
      yield (actions: actions.add(Action.forward), visited: visited);
      return;
    }
    if (validPositions.contains(forward)) {
      final forwardPaths = _allPossiblePaths(
        forward,
        visited.add(current),
        actions.add(Action.forward),
        facing,
        false,
        depth + 1,
      );
      yield* forwardPaths;
    }

    if (didTurn) {
      assert(actions.last.isTurn);
      return;
    }
    assert(!visited.contains(current));

    final right = facing.rotatedRight.modify(current);
    if (validPositions.contains(right)) {
      final rightPaths = _allPossiblePaths(
        current,
        visited,
        actions.add(Action.turnRight),
        facing.rotatedRight,
        true,
        depth + 1,
      );
      yield* rightPaths;
    }

    final left = facing.rotatedLeft.modify(current);
    if (validPositions.contains(left)) {
      final leftPaths = _allPossiblePaths(
        current,
        visited,
        actions.add(Action.turnLeft),
        facing.rotatedLeft,
        true,
        depth + 1,
      );
      yield* leftPaths;
    }
  }
}

enum Action {
  forward,
  turnLeft,
  turnRight;

  bool get isTurn => this == Action.turnLeft || this == Action.turnRight;
}
