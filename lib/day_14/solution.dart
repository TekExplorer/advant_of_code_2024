import 'dart:async';
import 'dart:io';

import 'package:advent_of_code_2024/advent_of_code_2024_v2.dart';
import 'package:advent_of_code_2024/files.dart';
import 'package:advent_of_code_2024/grid.dart';
import 'package:image/image.dart';

import '../direction.dart';

// Future<void> main() => Solution().solve();
// Future<void> main() => Solution().solveExample();
Future<void> main() => Solution().solveActual();

class Solution extends $Solution {
  @override
  get example => Example(part1: 12, part2: 0, '''
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
''');

  @override
  part1(Input input) {
    final constraints =
        input.isExample ? (width: 11, height: 7) : (width: 101, height: 103);

    final robots = input.robots(constraints);
    // robots.display();

    final robotsAfter100Seconds = robots.walkBy(seconds: 100);
    final quads = robotsAfter100Seconds.quadrants();
    // if (input.isExample) {
    //   robotsAfter100Seconds.display(hideMiddle: true);
    //   print('');
    //   assert(quads.toList().expand((element) => element).length == 9);
    //   print('');
    //   assert(quads.tl.numRobots == 1);
    //   assert(quads.tr.numRobots == 3);
    //   assert(quads.bl.numRobots == 4);
    //   assert(quads.br.numRobots == 1);
    //   for (final quad in quads.toList()) {
    //     print(quad.length);
    //   }
    // }
    return quads
        .toList()
        .map((e) => e.numRobots)
        .reduce((result, count) => result * count);
  }

  @override
  part2(Input input) async {
    if (input.isExample) return 0;
    final constraints = (width: 101, height: 103);
    Iterable<(int, Iterable<Robot>)> indexedBots(
      Iterable<Robot> robots, {
      int seconds = 5000,
    }) sync* {
      robots = robots.walkBy(seconds: seconds);
      while (true) {
        robots = robots.walkBy(seconds: 1);
        seconds++;
        // if (seconds % 500 case 0) debugger();
        if (robots.hasPals(constraints: constraints)) {
          yield (seconds, robots);
        }
        if (seconds >= 10_000) {
          throw Exception('Exceeded 10,000 seconds. cant handle this.');
        }
      }
    }

    final iterBots = indexedBots(input.robots(constraints), seconds: 7000);

    final iterator = iterBots.iterator;
    iterator.moveNext();
    final (seconds, robots) = iterator.current;
    print(seconds);
    robots.display();
    if (!out(seconds).existsSync()) {
      writeBotsImg(robots, out(seconds), constraints);
    }

    return seconds;
  }
}

const palValue = 6;

void writeBotsImg(Iterable<Robot> robots, File file, Constraints constraints) {
  final img = Image(width: constraints.width, height: constraints.height);
  for (final bot in robots) {
    var pixel = img.getPixel(bot.pos.x, bot.pos.y);
    pixel
      ..r = 255
      ..g = 255
      ..b = 255;
  }
  final data = encodePng(img);
  file.writeAsBytesSync(data);
}

File out(int count) => outputs.file('$count.png');

extension type Quadrant(Iterable<Robot> _) implements Iterable<Robot> {}
typedef Constraints = ({int height, int width});

class Robot {
  factory Robot.parse(String line, {required Constraints constraints}) {
    final match = RegExp(r'p=(\d+),(\d+) v=(-?\d+),(-?\d+)').firstMatch(line)!;
    return Robot(
      pos: (
        x: match[1]!.also(int.parse),
        y: match[2]!.also(int.parse),
      ),
      velocity: (
        x: match[3]!.also(int.parse),
        y: match[4]!.also(int.parse),
      ),
      constraints: constraints,
    );
  }
  Robot({
    required this.pos,
    required this.velocity,
    required this.constraints,
  });

  final Constraints constraints;
  final XY pos;
  final XY velocity;

  Robot walkBy({required int seconds}) {
    final dx = velocity.x * seconds;
    final dy = velocity.y * seconds;

    final XY newPos = (
      x: pos.x + dx,
      y: pos.y + dy,
    );
    return copyWith(pos: constraints.constrainWrapped(newPos));
  }

  Robot copyWith({
    XY? pos,
    XY? velocity,
    Constraints? constraints,
  }) =>
      Robot(
        pos: pos ?? this.pos,
        velocity: velocity ?? this.velocity,
        constraints: constraints ?? this.constraints,
      );

  @override
  String toString() => 'p=${pos.x},${pos.y}'; // v=${velocity.x},${velocity.y}';
}

extension on Constraints {
  XY constrainWrapped(XY target) {
    var x = ((target.x + 1) % width) - 1;
    if (x == -1) x = width - 1;
    var y = ((target.y + 1) % height) - 1;
    if (y == -1) y = height - 1;

    return (
      x: x,
      y: y,
    );
  }

  int get xMiddle => (width / 2).ceil();
  int get yMiddle => (height / 2).ceil();
}

extension on Input {
  Iterable<Robot> robots(Constraints constraints) =>
      lines.map((l) => Robot.parse(l, constraints: constraints));
}

extension on Iterable<Robot> {
  Quadrants quadrants() {
    final Constraints constraints = first.constraints;
    // -1 for indexing
    final x = constraints.xMiddle - 1;
    final y = constraints.yMiddle - 1;
    // xMiddle = 5
    // pos.x == 5 == hide
    return (
      tl: Quadrant(where((r) => r.pos.x < x && r.pos.y < y)),
      tr: Quadrant(where((r) => r.pos.x > x && r.pos.y < y)),
      bl: Quadrant(where((r) => r.pos.x < x && r.pos.y > y)),
      br: Quadrant(where((r) => r.pos.x > x && r.pos.y > y)),
    );
  }

  int get numRobots => length;
  Iterable<Robot> walkBy({required int seconds}) =>
      map((e) => e.walkBy(seconds: seconds));

  void display({
    bool hideMiddle = false,
    Constraints? constraints,
    StringBuffer? buffer,
  }) {
    bool didProvideBuffer = buffer != null;
    constraints ??= first.constraints;
    final middleY = (constraints.height / 2).floor();
    final middleX = (constraints.width / 2).floor();
    buffer ??= StringBuffer();
    for (var y = 0; y < constraints.height; y++) {
      for (var x = 0; x < constraints.width; x++) {
        if (hideMiddle && (y == middleY || x == middleX)) {
          buffer.write(' ');
          continue;
        }
        final numRobots = count((element) => element.pos == (x: x, y: y));
        if (numRobots == 0) {
          buffer.write('.');
        } else {
          buffer.write(numRobots);
        }
      }
      buffer.writeln();
    }
    buffer.writeln();
    if (!didProvideBuffer) print(buffer.toString());
  }

  bool hasPals({Constraints? constraints}) {
    constraints ??= first.constraints;
    final positions = map((e) => e.pos).toSet();
    for (final pos in positions) {
      final hBuddies = [pos];
      for (var i = 0; i < palValue; i++) {
        hBuddies.add(Direction.right.modify(hBuddies.last));
      }
      final vBuddies = [pos];
      for (var i = 0; i < palValue; i++) {
        vBuddies.add(Direction.down.modify(vBuddies.last));
      }
      if (positions.containsAll([...hBuddies, ...vBuddies])) {
        return true;
      }
    }
    return false;
  }
}

typedef Quadrants = ({
  Quadrant tl,
  Quadrant tr,
  Quadrant bl,
  Quadrant br,
});

extension on Quadrants {
  List<Quadrant> toList() => [tl, tr, bl, br];
}
