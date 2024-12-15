import 'package:advent_of_code_2024/grid.dart';

enum Direction {
  up,
  down,
  left,
  right;

  XY modify(XY pos, [int times = 1]) => switch (this) {
        Direction.up => (x: pos.x, y: pos.y - times),
        Direction.down => (x: pos.x, y: pos.y + times),
        Direction.left => (x: pos.x - times, y: pos.y),
        Direction.right => (x: pos.x + times, y: pos.y),
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

  bool get isHorizontal => this == Direction.left || this == Direction.right;
  bool get isVertical => this == Direction.up || this == Direction.down;
}

extension XYDirection on XY {
  XY shift(Direction direction, [int times = 1]) =>
      direction.modify(this, times);
  XY get up => shift(Direction.up);
  XY get down => shift(Direction.down);
  XY get left => shift(Direction.left);
  XY get right => shift(Direction.right);

  XY shiftDiagonal(Diagonal diagonal, [int times = 1]) =>
      diagonal.modify(this, times);

  XY get upLeft => up.left;
  XY get upRight => up.right;
  XY get downLeft => down.left;
  XY get downRight => down.right;

  // XY get upLeft => shiftDiagonal(Diagonal.upLeft);
  // XY get upRight => shiftDiagonal(Diagonal.upRight);
  // XY get downLeft => shiftDiagonal(Diagonal.downLeft);
  // XY get downRight => shiftDiagonal(Diagonal.downRight);
}

enum Diagonal {
  upLeft,
  upRight,
  downLeft,
  downRight;

  Set<Direction> get parts => switch (this) {
        Diagonal.upLeft => {Direction.up, Direction.left},
        Diagonal.upRight => {Direction.up, Direction.right},
        Diagonal.downLeft => {Direction.down, Direction.left},
        Diagonal.downRight => {Direction.down, Direction.right},
      };

  XY modify(XY pos, [int times = 1]) => switch (this) {
        Diagonal.upLeft => (x: pos.x - times, y: pos.y - times),
        Diagonal.upRight => (x: pos.x + times, y: pos.y - times),
        Diagonal.downLeft => (x: pos.x - times, y: pos.y + times),
        Diagonal.downRight => (x: pos.x + times, y: pos.y + times),
      };

  Diagonal get rotated90 => switch (this) {
        Diagonal.upLeft => downLeft,
        Diagonal.upRight => upLeft,
        Diagonal.downLeft => downRight,
        Diagonal.downRight => upRight,
      };
  Diagonal operator -() => opposite;
  Diagonal get opposite => switch (this) {
        Diagonal.upLeft => downRight,
        Diagonal.upRight => downLeft,
        Diagonal.downLeft => upRight,
        Diagonal.downRight => upLeft,
      };
}
