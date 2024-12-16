import 'package:advent_of_code_2024/grid.dart';
import 'package:collection/collection.dart';

sealed class CompassDirection implements Comparable<CompassDirection> {
  static CompassDirection? fromRotation(int rotation) {
    final normalized = rotation % 360;
    if (normalized < 0) return CompassDirection.fromRotation(normalized + 360);
    return CompassDirection.values.firstWhereOrNull(
      (direction) => direction.rotation == normalized,
    );
  }

  XY modify(XY pos, [int times = 1]);
  int get rotation;

  static const up = Direction.up;
  static const upRight = Diagonal.upRight;
  static const right = Direction.right;
  static const downRight = Diagonal.downRight;
  static const down = Direction.down;
  static const downLeft = Diagonal.downLeft;
  static const left = Direction.left;
  static const upLeft = Diagonal.upLeft;
  static const values = <CompassDirection>[
    up,
    upRight,
    right,
    downRight,
    down,
    downLeft,
    left,
    upLeft,
  ];
}

extension on CompassDirection {
  int _compareTo(CompassDirection other) => rotation.compareTo(other.rotation);
}

enum Direction implements CompassDirection {
  up,
  down,
  left,
  right;

  @override
  int compareTo(CompassDirection other) => _compareTo(other);
  @override
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
  Direction get rotatedRight => rotated90;

  Direction get rotated270 => -rotated90;
  Direction get rotatedLeft => rotated270;

  Direction operator -() => opposite;
  Direction get opposite => switch (this) {
        Direction.up => down,
        Direction.down => up,
        Direction.left => right,
        Direction.right => left,
      };

  bool get isHorizontal => this == Direction.left || this == Direction.right;
  bool get isVertical => this == Direction.up || this == Direction.down;

  Diagonal get rotatedMinus45 => switch (this) {
        Direction.up => Diagonal.upLeft,
        Direction.down => Diagonal.downRight,
        Direction.left => Diagonal.downLeft,
        Direction.right => Diagonal.upRight,
      };
  Diagonal get rotated45 => switch (this) {
        Direction.up => Diagonal.upRight,
        Direction.down => Diagonal.downLeft,
        Direction.left => Diagonal.upLeft,
        Direction.right => Diagonal.downRight,
      };

  // in degrees
  @override
  int get rotation => switch (this) {
        Direction.up => 0,
        Direction.right => 90,
        Direction.down => 180,
        Direction.left => 270,
      };
}

extension XYDirection on XY {
  XY modify(CompassDirection direction, [int times = 1]) =>
      direction.modify(this, times);

  XY up([int times = 1]) => modify(Direction.up, times);
  XY down([int times = 1]) => modify(Direction.down, times);
  XY left([int times = 1]) => modify(Direction.left, times);
  XY right([int times = 1]) => modify(Direction.right, times);

  XY upLeft([int times = 1]) => up(times).left(times);
  XY upRight([int times = 1]) => up(times).right(times);
  XY downLeft([int times = 1]) => down(times).left(times);
  XY downRight([int times = 1]) => down(times).right(times);
}

enum Diagonal implements CompassDirection {
  upRight,
  downRight,
  downLeft,
  upLeft;

  @override
  int compareTo(CompassDirection other) => _compareTo(other);

  @override
  XY modify(XY pos, [int times = 1]) => switch (this) {
        upLeft => (x: pos.x - times, y: pos.y - times),
        upRight => (x: pos.x + times, y: pos.y - times),
        downLeft => (x: pos.x - times, y: pos.y + times),
        downRight => (x: pos.x + times, y: pos.y + times),
      };

  Diagonal get rotated90 => switch (this) {
        upLeft => downLeft,
        upRight => upLeft,
        downLeft => downRight,
        downRight => upRight,
      };
  Diagonal operator -() => opposite;
  Diagonal get rotated180 => opposite;
  Diagonal get opposite => switch (this) {
        upLeft => downRight,
        upRight => downLeft,
        downLeft => upRight,
        downRight => upLeft,
      };

  Direction get vertical => switch (this) {
        upLeft || upRight => Direction.up,
        downLeft || downRight => Direction.down,
      };
  Direction get horizontal => switch (this) {
        upLeft || downLeft => Direction.left,
        upRight || downRight => Direction.right,
      };

  bool get isUp => this == upLeft || this == upRight;
  bool get isDown => this == downLeft || this == downRight;
  bool get isLeft => this == upLeft || this == downLeft;
  bool get isRight => this == upRight || this == downRight;

  Direction get rotatedMinus45 => switch (this) {
        upLeft => Direction.left,
        upRight => Direction.up,
        downLeft => Direction.down,
        downRight => Direction.right,
      };

  Direction get rotated45 => switch (this) {
        upLeft => Direction.up,
        upRight => Direction.right,
        downLeft => Direction.left,
        downRight => Direction.down,
      };

  @override
  int get rotation => switch (this) {
        upRight => 45,
        downRight => 135,
        downLeft => 225,
        upLeft => 315,
      };
}
