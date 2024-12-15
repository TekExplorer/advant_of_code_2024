import 'dart:async';
import 'dart:developer';

import 'package:advent_of_code_2024/advent_of_code_2024_v2.dart';
import 'package:advent_of_code_2024/direction.dart';
import 'package:advent_of_code_2024/grid.dart';
import 'package:collection/collection.dart';

// Future<void> main() => Solution().solve();
// Future<void> main() => Solution().solveExample();
Future<void> main() => Solution().solveActual();

class Solution extends $Solution {
  Example get exampleLarge => Example(part1: 10092, part2: 9021, '''
##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
''');
  Example get exampleSmall => Example(part1: 2028, part2: 0, '''
########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<
''');

  @override
  // get example => exampleSmall;
  get example => exampleLarge;

  @override
  part1(Input input) {
    final (grid, actions) = input.puzzle();
    for (final action in actions) {
      grid.moveRobot(action);
    }
    final allGps = grid.boxes.map((b) => b.gps);
    return allGps.sum;
  }

  @override
  part2(Input input) {
    final (grid, actions) = input.widePuzzle();
    print(grid);
    for (final action in actions) {
      //
      // print('Moving ${action.name}');
      grid.moveRobot(action);
      // print(grid);
    }
    final allGps = grid.boxes.map((b) => b.gps);
    return allGps.sum;
  }
}

extension on Char {
  bool get isWall => char == '#';
  bool get isBox => char == 'O';
  bool get isWideBox => isLeftWideBox || isRightWideBox;
  bool get isLeftWideBox => char == '[';
  bool get isRightWideBox => char == ']';
}

extension on XY {
  // The GPS coordinate of a box is equal to 100 times its distance from the
  // top edge of the map plus its distance from the left edge of the map.
  int get gps => y * 100 + x;
}

extension on Grid {
  XY get robot => posOf(Char('@'))!;
}

extension on Input {
  (_Part1Grid, Iterable<Direction>) puzzle() {
    final (map, actionsLines) = lines.splitAt(lines.indexOf(''));

    final actions = actionsLines
        .join()
        .split('')
        .map((a) => switch (a) {
              '^' => Direction.up,
              'v' => Direction.down,
              '<' => Direction.left,
              '>' => Direction.right,
              _ => null,
            })
        .nonNulls;

    return (
      _Part1Grid(Grid.of(map.join('\n'))),
      actions,
    );
  }

  (_Part2Grid, Iterable<Direction>) widePuzzle() {
    final (map, actionsLines) = lines.splitAt(lines.indexOf(''));

    final actions = actionsLines
        .join()
        .split('')
        .map((a) => switch (a) {
              '^' => Direction.up,
              'v' => Direction.down,
              '<' => Direction.left,
              '>' => Direction.right,
              _ => null,
            })
        .nonNulls;
    // make wide. # -> ## and O -> [] and @ -> @. and . -> ..
    final wideMap = map.map((line) => line
        .split('')
        .map((c) => switch (c) {
              '#' => '##',
              'O' => '[]',
              '@' => '@.',
              '.' => '..',
              _ => throw StateError('Invalid char: $c'),
            })
        .join());

    return (
      _Part2Grid(Grid.of(wideMap.join('\n'))),
      actions,
    );
  }
}

extension type _Part1Grid(Grid _) implements Grid {
  Iterable<XY> get boxes => allPosOf(Char('O'));
  bool moveRobot(Direction direction) {
    final robot = this.robot;
    final targetPos = direction.modify(robot);
    final atTarget = this[targetPos];
    if (atTarget.isWall) return false;

    bool move() {
      this[robot] = Char.dot;
      this[targetPos] = Char('@');
      return true;
    }

    if (atTarget.isDot) return move();

    if (atTarget.isBox) {
      // multi-push boxes.
      // check past the box. if theres a box, keep looking.
      // if theres a wall, return false
      // if theres a space, set that to a box and move the bot to emulate multipush
      var therePos = targetPos;
      var there = atTarget;
      while (there.isBox) {
        therePos = direction.modify(therePos);
        there = this[therePos];
        if (there.isWall) return false;
        if (there.isBox) continue;
        this[therePos] = Char('O');
        return move();
      }
    }
    throw StateError('Invalid target: $atTarget at $targetPos');
  }
}

extension type _Part2Grid(Grid _) implements Grid {
  Iterable<XY> get boxes => allPosOf(Char('['));
  bool moveRobot(Direction direction) {
    final robot = this.robot;
    final targetPos = direction.modify(robot);
    final atTarget = this[targetPos];
    if (atTarget.isWall) return false;

    bool move() {
      this[robot] = Char.dot;
      this[targetPos] = Char('@');
      return true;
    }

    if (atTarget.isDot) return move();

    if (atTarget.isWideBox) {
      if (moveBox(targetPos, direction)) {
        return move();
      } else {
        return false;
      }
    }
    throw StateError('Invalid target: $atTarget at $targetPos');
  }

  bool moveBox(XY box, Direction direction) {
    final grid = _Part2Grid(clone());
    var didMoveBox = grid._moveBox(box, direction, 0);
    if (didMoveBox) setFrom(grid);
    return didMoveBox;
  }

  // moving a wide box
  bool _moveBox(XY box, Direction direction, int depth) {
    final thisBoxHalf = this[box];
    if (thisBoxHalf.isDot) debugger();
    final (boxLeft, boxRight) = switch (thisBoxHalf) {
      '[' => (box, box.right),
      ']' => (box.left, box),
      _ => throw StateError('Invalid box: $thisBoxHalf at $box'),
    };
    bool moveBox() {
      this[boxLeft] = Char.dot;
      this[boxRight] = Char.dot;
      this[boxLeft.shift(direction)] = Char('[');
      this[boxRight.shift(direction)] = Char(']');
      return true;
    }

    switch (direction) {
      case Direction.up || Direction.down:
        final leftTarget = boxLeft.shift(direction);
        final rightTarget = boxRight.shift(direction);
        final atLeft = this[leftTarget];
        final atRight = this[rightTarget];
        if (atLeft.isWall || atRight.isWall) return false;
        if (atLeft.isDot && atRight.isDot) return moveBox();

        if (atLeft.isWideBox) {
          if (!_moveBox(leftTarget, direction, depth + 1)) return false;
        }
        if (!atLeft.isLeftWideBox && atRight.isWideBox) {
          if (!_moveBox(rightTarget, direction, depth + 1)) return false;
        }

        return moveBox();
      case Direction.left:
        final target = boxLeft.left;
        final atTarget = this[target];
        if (atTarget.isWall) return false;
        if (atTarget.isWideBox) {
          if (!_moveBox(target, direction, depth + 1)) return false;
        }

        return moveBox();
      case Direction.right:
        final target = boxRight.right;
        final atTarget = this[target];
        if (atTarget.isWall) return false;
        if (atTarget.isWideBox) {
          if (!_moveBox(target, direction, depth + 1)) return false;
        }
        return moveBox();
    }
  }
}
