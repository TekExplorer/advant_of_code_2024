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

  XY modify(XY pos) => switch (this) {
        Diagonal.upLeft => (x: pos.x - 1, y: pos.y - 1),
        Diagonal.upRight => (x: pos.x + 1, y: pos.y - 1),
        Diagonal.downLeft => (x: pos.x - 1, y: pos.y + 1),
        Diagonal.downRight => (x: pos.x + 1, y: pos.y + 1),
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
