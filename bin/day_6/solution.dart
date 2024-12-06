import 'dart:async';

import 'package:advent_of_code_2024/advent_of_code_2024.dart';
import 'package:collection/collection.dart';

Future<void> main() => Solution().solve();

enum Direction {
  up('^'),
  down('v'),
  left('<'),
  right('>');

  const Direction(this.char);
  static Direction? fromChar(String char) =>
      values.where((e) => e.char == char).firstOrNull;

  final String char;

  Direction get rotated90 => switch (this) {
        Direction.up => right,
        Direction.down => left,
        Direction.left => up,
        Direction.right => down,
      };

  Location modify(Location pos) => switch (this) {
        // the y's are inverted, since up is "earlier"
        Direction.up => (x: pos.x, y: pos.y - 1),
        Direction.down => (x: pos.x, y: pos.y + 1),
        //
        Direction.left => (x: pos.x - 1, y: pos.y),
        Direction.right => (x: pos.x + 1, y: pos.y),
      };
}

typedef Location = ({int x, int y});
typedef Position = ({Location pos, Direction facing});

enum Result { gone, looped }

class GuardWalker {
  GuardWalker(this.source) {
    startingPosition = source.guardPos!;
  }

  final GridView source;

  late Position startingPosition;

  late GridView map = source.clone();
  final positionsBeenIn = <Position>{};

  void set(Location pos, String value) {
    if (pos.y < map.grid.length && pos.x < map[pos.x].length) {
      map[pos.y][pos.x] = value;
    } else {
      throw StateError('Invalid position');
    }
  }

  String valueAt(Location pos) {
    try {
      return map[pos.y][pos.x];
    } catch (e) {
      // empty represents outside of the map
      return '';
    }
  }

  Result? _result;
  Result travel() {
    if (map.guardPos == null) throw StateError('Guard is missing');
    return _result ??= _walk(startingPosition);
  }

  Result _walk(({Location pos, Direction facing}) currentPosition) {
    if (!positionsBeenIn.add(currentPosition)) return Result.looped;

    final (:pos, :facing) = currentPosition;

    final positionFaced = facing.modify(pos);

    // facing a barrier?
    if (valueAt(positionFaced) case '#' || 'O') {
      set(pos, facing.rotated90.char);
      return _walk((facing: facing.rotated90, pos: pos));
    } else {
      set(pos, 'X');
      // dont try to set a position if we're leaving the board
      if (valueAt(positionFaced) case '') return Result.gone;
      set(positionFaced, facing.char);
      return _walk((facing: facing, pos: positionFaced));
    }
  }

  int get numUniqueVisited =>
      map.grid.expand((e) => e).where((e) => e == 'X').length;
}

class Solution extends $Solution {
  String get contents => '''
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
'''
      .trim();
  // 41
  // 6

  // Iterable<String> get lines => contents.lines;

  @override
  part1() {
    final guard = GuardWalker(grid);
    guard.travel();
    return guard.numUniqueVisited.toString();
  }

  late GridView grid = GridView(lines.map((e) => e.split('')).toList());

  // WARNING: Slow!
  @override
  part2() {
    final guard = GuardWalker(grid)..travel();
    final splayed = grid.splay(guard.positionsBeenIn.map((e) => e.pos));

    int numGridsThatLoop = 0;
    for (final grid in splayed) {
      final guard = GuardWalker(grid);
      if (guard.travel() case Result.looped) {
        numGridsThatLoop++;
      }
    }

    return numGridsThatLoop.toString();
  }
}

// could split into mutable and immutable extension types.
// some other time perhaps.
class GridView {
  GridView(this.grid);
  final List<List<String>> grid;

  GridView clone() => GridView([
        for (final line in grid) [...line]
      ]);

  void display() {
    for (final line in grid) {
      print(line.join(' '));
    }
  }

  Iterable<GridView> splay(Iterable<Location> locations) sync* {
    for (final (:x, :y) in locations.toSet()) {
      if (grid[y][x] != '.') continue;
      final copy = clone();
      copy[y][x] = 'O';
      yield copy;
    }
  }

  Position? get guardPos {
    for (final (y, row) in grid.indexed) {
      for (final (x, value) in row.indexed) {
        if (Direction.fromChar(value) case final direction?) {
          return (pos: (x: x, y: y), facing: direction);
        }
      }
    }
    return null;
  }

  List<String> operator [](int y) => grid[y];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GridView &&
        DeepCollectionEquality().equals(other.grid, grid);
  }

  @override
  int get hashCode => DeepCollectionEquality().hash(grid);
}
