import 'dart:async';

import 'package:advent_of_code_2024/advent_of_code_2024.dart';

Future<void> main() => Solution().solve();

enum Operator { plus, mult, concat }

class Solution extends $Solution {
  String get contents => '''
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
'''
      .trim(); // 3749, 11387

// operators: + *
  @override
  part1() => doWithEnabledOperators([
        Operator.mult,
        Operator.plus,
      ]);

  @override
  part2() => doWithEnabledOperators([
        Operator.mult,
        Operator.plus,
        Operator.concat,
      ]);

  int doWithEnabledOperators(List<Operator> operators) {
    // final lines = contents.lines;
    final stuff = lines.map((line) {
      final [desired, nums] = line.split(': ');
      return (
        goal: int.parse(desired),
        operands: nums.split(' ').map(int.parse).toList()
      );
    });
    int solution = 0;
    for (final (:goal, :operands) in stuff) {
      print('Doing $goal: ${operands.join(' ')}');
      final numOperators = operands.length - 1;
      final operatorCombinations = Amalgams(numOperators, operators);
      for (final operators in operatorCombinations()) {
        int value = operands.first;
        for (var i = 0; i < numOperators; i++) {
          final rhs = operands[i + 1];
          switch (operators[i]) {
            case Operator.plus:
              value += rhs;
            case Operator.mult:
              value *= rhs;
            case Operator.concat:
              value = int.parse('$value$rhs');
          }
        }
        if (value == goal) {
          solution += value;
          break;
        }
      }
    }
    return solution;
  }
}
