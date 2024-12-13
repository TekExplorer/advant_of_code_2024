import 'dart:async';

import 'package:advent_of_code_2024/advent_of_code_2024_v2.dart';
import 'package:collection/collection.dart';
import 'package:vector_math/vector_math_64.dart';

Future<void> main() => Solution().solve();
// Future<void> main() => Solution().solveExample();
// Future<void> main() => Solution().solveActual();

class Solution extends $Solution {
  @override
  get example => Example(part1: 480, part2: 0, '''
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
''');

  @override
  part1(Input input) {
    final games = input.games;
    // print(games.join('\n\n'));
    // return games.map((e) => e.bruteForceSolve()).nonNulls.sum; // part 1 attempt. it DID work.
    return games.map((e) => e.solveByMatrix()).nonNulls.sum;
  }

  @override
  part2(Input input) {
    final games = input.games;
    // print(games.join('\n\n'));
    // for (final game in games) {
    //   final matrix = game.solveByMatrix();
    //   print(matrix);
    // }
    final gamesWithTwist = games.map((e) => Game(
          e.buttonA,
          e.buttonB,
          Prize(
            x: e.prize.x + twist,
            y: e.prize.y + twist,
          ),
        ));
    return gamesWithTwist.map((e) => e.solveByMatrix()).nonNulls.sum;
  }
}

extension on Input {
  Iterable<Game> get games sync* {
    final lines = this.lines.whereNot((l) => l.isEmpty).window(3, step: 3);
    for (final [a, b, p] in lines) {
      yield Game(
        Button.parse(a),
        Button.parse(b),
        Prize.parse(p),
      );
    }
  }
}

// limit by 100

enum ButtonKind { A, B }

class Button {
  Button({required this.dx, required this.dy, required this.label});
  // Button A: X+69, Y+23
  // Button B: X+84, Y+37
  factory Button.parse(String line) {
    var allMatches =
        RegExp(r'Button (A|B): X\+(\d+), Y\+(\d+)').allMatches(line);
    final match = allMatches.single;

    return Button(
      label: match[1]!,
      dx: int.parse(match[2]!),
      dy: int.parse(match[3]!),
    );
  }
  final String label;
  final int dx;
  final int dy;

  @override
  String toString() => 'Button $label: X+$dx, Y+$dy';
}

class Prize {
  Prize({required this.x, required this.y});
  // Prize: X=18641, Y=10279
  factory Prize.parse(String line) {
    final match = RegExp(r'Prize: X=(\d+), Y=(\d+)').allMatches(line).single;
    return Prize(
      x: int.parse(match[1]!),
      y: int.parse(match[2]!),
    );
  }

  final int x;
  final int y;

  @override
  String toString() => 'Prize: X=$x, Y=$y';
}

class Game {
  Game(this.buttonA, this.buttonB, this.prize);
  final Button buttonA;
  final Button buttonB;
  final Prize prize;

  @override
  String toString() => [buttonA, buttonB, prize].join('\n');
  bool isValid(PossibleSolution sol) {
    int x = 0;
    x += buttonA.dx * sol.aPresses;
    x += buttonB.dx * sol.bPresses;
    if (x != prize.x) return false;

    int y = 0;
    y += buttonA.dy * sol.aPresses;
    y += buttonB.dy * sol.bPresses;
    if (y != prize.y) return false;

    return true;
  }

  // x() {
  //   '${buttonA.dx}A + ${buttonB.dx}B = ${prize.x}';
  //   '${buttonA.dy}A + ${buttonB.dy}B = ${prize.y}';
  // }
}

const twist = 10_000_000_000_000;

// button limit is 100 each for pt1
extension BruteForce on Game {
  int? bruteForceSolve() {
    final validOptions = possiblePressesLimitedTo100.where(isValid);
    final tokenCosts = validOptions.map((o) => o.tokenCost);
    if (tokenCosts.isEmpty) return null;
    return tokenCosts.min;
  }

  // inefficient
  Iterable<PossibleSolution> get possiblePressesLimitedTo100 sync* {
    for (var aPresses = 0; aPresses <= 100; aPresses++) {
      for (var bPresses = 0; bPresses <= 100; bPresses++) {
        yield (aPresses: aPresses, bPresses: bPresses);
      }
    }
  }
}

extension on Game {
  // '${buttonA.dx}A + ${buttonB.dx}B = ${prize.x}';
  // '${buttonA.dy}A + ${buttonB.dy}B = ${prize.y}';

  // aX+bY=c

  int? solveByMatrix() {
    final x = Vector2.zero();
    {
      final A = Matrix2.zero()
        ..row0 = Vector2(buttonA.dx.toDouble(), buttonB.dx.toDouble())
        ..row1 = Vector2(buttonA.dy.toDouble(), buttonB.dy.toDouble());

      final b = Vector2(
        prize.x.toDouble(),
        prize.y.toDouble(),
      );
      Matrix2.solve(A, x, b);
    }
    // round for floating point precision issues.
    final a = x.x.round();
    final b = x.y.round();
    // lets make sure its an actual solution
    if (!isValid((aPresses: a, bPresses: b))) return null;
    return (a * 3) + b;
  }
}

typedef PossibleSolution = ({int aPresses, int bPresses});

extension on PossibleSolution {
  int get tokenCost => (aPresses * 3) + (bPresses * 1);
}
