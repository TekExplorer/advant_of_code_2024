import 'dart:async';
import 'dart:collection';

import 'package:advent_of_code_2024/advent_of_code_2024_v2.dart';

Future<void> main() => Solution().solve();

typedef Pos = ({int x, int y});

typedef AllPositions = HashMap<String, Positions>;
typedef Positions = HashSet<Pos>;

class Solution extends $Solution {
  @override
  get example => Example(part1: 14, part2: 34, '''
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
''');

  AllPositions positionsOf(Iterable<String> lines) {
    final positions = HashMap<String, HashSet<Pos>>();
    for (final (y, line) in lines.indexed) {
      for (final (x, char) in line.split('').indexed) {
        if (char != '.') {
          positions[char] ??= HashSet<Pos>();
          positions[char]!.add((x: x, y: y));
        }
      }
    }
    return positions;
  }

  Set<Pos> antinodesOf(Positions positions) {
    final antinodes = <Pos>{};
    for (final [a, b] in positions.combinations(2)) {
      final [l, r] = antinodesFor(a, b);
      antinodes.add(l);
      antinodes.add(r);
    }
    return antinodes;
  }

  HashSet<Pos> allAntinodesOf(AllPositions positions) {
    final set = HashSet<Pos>();
    for (final pos in positions.values) {
      set.addAll(antinodesOf(pos));
    }
    return set;
  }

  bool isConstrainedBy(Pos pos, ({int width, int height}) constraints) {
    final (:width, :height) = constraints;
    if (pos.x < 0 || pos.y < 0) return false;
    if (pos.x >= width || pos.y >= height) return false;
    return true;
  }

  List<Pos> antinodesFor(Pos a, Pos b) {
    // always 2
    final dx = b.x - a.x;
    final dy = a.y - b.y;

    return [
      (
        x: a.x - dx,
        y: a.y + dy,
      ),
      (
        x: b.x + dx,
        y: b.y - dy,
      ),
    ];
  }

  void display(
    Iterable<String> source, {
    Iterable<Pos>? antinodes,
    bool changeTower = false,
  }) {
    if (antinodes == null) {
      return print(source.join('\n'));
    }

    final grid = source.toList().map((e) => e.split('').toList()).toList();
    for (final node in antinodes) {
      if (changeTower || grid[node.y][node.x] == '.') {
        grid[node.y][node.x] = '#';
      }
    }
    display(grid.map((e) => e.join()));
  }

  @override
  part1(Input input) {
    final lines = input.lines;
    final height = lines.length;
    final width = lines.first.length;
    final positions = positionsOf(lines);
    final antinodes = allAntinodesOf(positions).where((node) {
      return isConstrainedBy(node, (width: width, height: height));
    });
    assert(() {
      try {
        for (final node in antinodes) {
          lines[node.x][node.y];
        }
        return true;
      } catch (e) {
        return false;
      }
    }(), 'Antinodes were not valid');
    // display(lines);
    // print('\n');
    // display(lines, antinodes: antinodes);
    return antinodes.length;
  }

  Iterable<Pos> infinitePossibleAntinodes(
    Pos a,
    Pos b, {
    required ({int width, int height}) constraints,
  }) sync* {
    final dx = b.x - a.x;
    final dy = a.y - b.y;
    int i1 = 1;
    while (true) {
      final pos = (
        x: a.x - dx * i1,
        y: a.y + dy * i1,
      );
      if (!isConstrainedBy(pos, constraints)) break;
      yield pos;
      i1++;
    }
    int i2 = 1;
    while (true) {
      final pos = (
        x: a.x + dx * i2,
        y: a.y - dy * i2,
      );
      if (!isConstrainedBy(pos, constraints)) break;
      yield pos;
      i2++;
    }
  }

  HashSet<Pos> allInfiniteAntinodesOf(
    AllPositions positions, {
    required ({int width, int height}) constraints,
  }) {
    final set = HashSet<Pos>();
    for (final pos in positions.values) {
      set.addAll([
        for (final [a, b] in pos.combinations(2))
          ...infinitePossibleAntinodes(a, b, constraints: constraints)
      ]);
    }
    return set;
  }

  // additionally, if an antenna meets with at least two towers, it is also one.
  @override
  part2(Input input) {
    final lines = input.lines;
    final height = lines.length;
    final width = lines.first.length;
    final positions = positionsOf(lines);
    final antinodes = allInfiniteAntinodesOf(
      positions,
      constraints: (width: width, height: height),
    );

    final resonantPositions = positions.values.where((e) => e.length > 1);
    for (final pos in resonantPositions) {
      antinodes.addAll(pos);
    }

    // display(lines);
    // print('\n');
    // display(
    //   lines,
    //   antinodes: antinodes,
    //   changeTower: true,
    // );
    return antinodes.length;
  }
}
