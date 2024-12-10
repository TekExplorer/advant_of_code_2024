import 'package:advent_of_code_2024/grid.dart';

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

  Direction get rotated90 => switch (this) {
        Direction.up => right,
        Direction.down => left,
        Direction.left => up,
        Direction.right => down,
      };

  Direction operator -() => opposite;
  Direction get opposite => switch (this) {
        Direction.up => down,
        Direction.down => up,
        Direction.left => right,
        Direction.right => left,
      };
}
