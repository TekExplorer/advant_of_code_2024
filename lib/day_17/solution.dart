import 'dart:async';

import 'package:advent_of_code_2024/advent_of_code_2024_v2.dart';

// Future<void> main() => Solution().solve();
// Future<void> main() => Solution().solveExample();
Future<void> main() => Solution().solveActual();
bool shouldDisplay = false;

class Solution extends $Solution {
  @override
  get example => Example(part1: '4,6,3,5,6,3,5,2,1,0', part2: 0, '''
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
''');

  @override
  part1(Input input) async {
    // If register C contains 9, the program 2,6 would set register B to 1.
    // final testComputer = Computer(registerC: 9, program: [2, 6].lock);
    // testComputer.run();
    // assert(testComputer.registerB == 1);

    final computer = Computer.parse(input.lines);
    computer.run();
    return computer.output;
  }

  @override
  part2(Input input) async {
    final lines = switch (input.isExample) {
      true => [
          'Register A: 2024',
          // 'Register A: 0',
          'Register B: 0',
          'Register C: 0',
          '', // expect 117440
          'Program: 0,3,5,4,3,0',
        ],
      false => input.lines,
    };
    final computer = Computer.parse(lines);
    // computer.run();
    // return computer.output;
    // return computer.findSelfEmittingValueForA(
    //   initial: 200_000_000,
    //   limit: 500_000_000,
    // );
    // 32768 = 2^15
    // final modifier = (computer.program.length * 2) + 3;
    // print('Modifier: $modifier');
    // final start = 2.pow(modifier) as int;
    // final end = 2.pow(modifier + 3) - 1 as int;
    // print('Will check ${end - start} values');

    return computer.part2();
    // return computer.findSelfEmittingValueForA(initial: 0, limit: end);
  }
}

class Computer {
  factory Computer.parse(Iterable<String> lines) {
    var [a, b, c, _, p] = lines.toList();
    a = a.removePrefix('Register A: ');
    b = b.removePrefix('Register B: ');
    c = c.removePrefix('Register C: ');
    p = p.removePrefix('Program: ');
    return Computer(
      registerA: int.parse(a),
      registerB: int.parse(b),
      registerC: int.parse(c),
      program: p.split(',').map(int.parse).toIList(),
    );
  }

  Computer({
    this.registerA = 0,
    this.registerB = 0,
    this.registerC = 0,
    required this.program,
  })  : _initialRegisterA = registerA,
        _initialRegisterB = registerB,
        _initialRegisterC = registerC;

  final int _initialRegisterA;
  final int _initialRegisterB;
  final int _initialRegisterC;
  final IList<int> program;

  void reset() {
    registerA = _initialRegisterA;
    registerB = _initialRegisterB;
    registerC = _initialRegisterC;
    outBuffer.clear();
    _pointer = 0;
  }

  int registerA;
  int registerB;
  int registerC;
  final outBuffer = <int>[];
  String get output => outBuffer.join(',');

  int _pointer = 0;
  void goTo(int index) => _pointer = index;
  void advancePointer() => _pointer += 2;
  (Opcode opcode, Operand operand) get nextInstruction => (
        Opcode(program[_pointer]),
        Operand(program[_pointer + 1], this),
      );

  void run() async {
    display();
    while (_pointer < program.length) {
      final (opcode, operand) = nextInstruction;
      _process(opcode, operand);
      display();
    }
    // halt();
  }

  void display() {
    if (!shouldDisplay) return;
    // print the current position of the program like:
    // 0,1,5,4,3,0
    //     ^

    print(this);
    print('         ${' ' * (_pointer * 2)}^ ^');
    print('Current Output: $output');
  }

  @override
  String toString() => '''
Register A: $registerA
Register B: $registerB
Register C: $registerC

Program: ${program.join(',')}
'''
      .trim();

// 729/(2^1)
  void _process(Opcode opcode, Operand operand) {
    //

    int adv() {
      return registerA ~/ 2.pow(operand.combo);
    }

    //   The eight instructions are as follows:
    switch (opcode.code) {
      // The adv instruction (opcode 0) performs division. The numerator is the value in the A register.
      // The denominator is found by raising 2 to the power of the instruction's combo operand.
      // (So, an operand of 2 would divide A by 4 (2^2); an operand of 5 would divide A by 2^B.)
      // The result of the division operation is truncated to an integer and then written to the A register.
      case 0:
        registerA = adv();
      // print('Register A: ${registerA.toRadixString(2)}');
      // The bxl instruction (opcode 1) calculates the bitwise XOR of register B and the instruction's literal operand, then stores the result in register B.
      case 1:
        registerB ^= operand.literal;

      // The bst instruction (opcode 2) calculates the value of its combo operand modulo 8 (thereby keeping only its lowest 3 bits), then writes that value to the B register.
      case 2:
        registerB = operand.combo % 8;
      // The jnz instruction (opcode 3) does nothing if the A register is 0.
      // However, if the A register is not zero, it jumps by setting the instruction pointer to the value of its literal operand; if this instruction jumps, the instruction pointer is not increased by 2 after this instruction.
      case 3:
        if (registerA != 0) {
          goTo(operand.literal);
          return;
        }
      // The bxc instruction (opcode 4) calculates the bitwise XOR of register B and register C, then stores the result in register B. (For legacy reasons, this instruction reads an operand but ignores it.)
      case 4:
        registerB ^= registerC;
      // The out instruction (opcode 5) calculates the value of its combo operand modulo 8, then outputs that value. (If a program outputs multiple values, they are separated by commas.)
      case 5:
        outBuffer.add(operand.combo % 8);
      // The bdv instruction (opcode 6) works exactly like the adv instruction except that the result is stored in the B register. (The numerator is still read from the A register.)
      case 6:
        registerB = adv();
      // The cdv instruction (opcode 7) works exactly like the adv instruction except that the result is stored in the C register. (The numerator is still read from the A register.)
      case 7:
        registerC = adv();
    }
    advancePointer();
  }

  // find the lowest possible value for register A that causes the program to output the program itself
  // HOW DID THIS WORK!?
  int part2() {
    final reversedProgram = program.reversed.toList();
    int window = 1;
    var valueStr = '';
    assert((valueStr.length / 3) == window - 1);

    while (output != program.join(',')) {
      final target = reversedProgram.take(window).toList().reversed.join(',');
      for (final i in ThreeBitInt.values) {
        final local = valueStr + i.stringify;
        final value = int.parse(local, radix: 2);
        reset();
        registerA = value;
        run();
        if (output.endsWith(target)) {
          print('Found it at $value');
          print('Found it at ${value.toRadixString(2)}');
          print('Output: $output');
          valueStr = local;
          window++;
          break;
        }
      }
      assert((valueStr.length / 3) == window - 1);
    }
    return int.parse(valueStr, radix: 2);
  }
}

enum ThreeBitInt {
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven;

  String get stringify => switch (this) {
        zero => '000',
        one => '001',
        two => '010',
        three => '011',
        four => '100',
        five => '101',
        six => '110',
        seven => '111',
      };
}

/**
Found it at 22163
Found it at 101011010010011
Output: 7,5,5,3,0
 */
extension type Opcode(int code) {}

class Operand {
  Operand(this.literal, this._state);
  final Computer _state;
  final int literal;
  int get combo => switch (literal) {
        < 4 => literal,
        4 => _state.registerA,
        5 => _state.registerB,
        6 => _state.registerC,
        7 => throw ArgumentError('Reserved operand'),
        _ => throw ArgumentError('Invalid operand'),
      };
}
/*
Literal operands is itself

Combo operands 0 through 3 represent literal values 0 through 3.
Combo operand 4 represents the value of register A.
Combo operand 5 represents the value of register B.
Combo operand 6 represents the value of register C.
Combo operand 7 is reserved and will not appear in valid programs.
*/
