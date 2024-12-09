import 'package:advent_of_code_2024/advent_of_code_2024_v2.dart';
import 'package:collection/collection.dart';

Future<void> main() => Solution().solve();
// Future<void> main() => Solution().solveExample();
// Future<void> main() => Solution().solveActual();

enum State { block, empty }

sealed class Part {
  static const empty = EmptyPart._();
}

class IntPart implements Part {
  const IntPart(this.value);
  final int value;
  @override
  String toString() => value.toString();
  @override
  operator ==(other) => other is IntPart && other.value == value;

  @override
  int get hashCode => value;
}

class EmptyPart implements Part {
  const EmptyPart._();
  @override
  String toString() => '.';
  @override
  operator ==(other) => other is EmptyPart;

  @override
  int get hashCode => (EmptyPart).hashCode;
}

class Solution extends $Solution {
  // disk map
  @override
  get example => Example(part1: 1928, part2: 2858, '2333133121414131402');
  // get example => Example(part1: 165, part2: 165, '1910101010101010101');

  Iterable<Part> decode(String diskMap) sync* {
    bool isBlock = true;
    int index = 0;
    for (final value in diskMap.split('')) {
      yield* ([
        for (int i = 0; i < int.parse(value); i++)
          if (isBlock) IntPart(index) else Part.empty,
      ]);
      if (isBlock) index++;

      isBlock = !isBlock;
    }
  }

  List<Part> compress(List<Part> sectors) {
    while (true) {
      // display(sectors);
      final indexFirstEmpty = sectors.indexOf(Part.empty);
      if (indexFirstEmpty < 0) return sectors;
      //
      final indexLastInt = sectors.lastIndexWhere((e) => e is IntPart);
      if (indexLastInt < indexFirstEmpty) return sectors;
      sectors.swap(indexFirstEmpty, indexLastInt);
    }
  }

  int checksum(Iterable<Part> sectors) {
    int chksm = 0;
    for (final (index, value) in sectors.indexed) {
      if (value is IntPart) chksm += (index * value.value);
    }
    return chksm;
  }

  @override
  part1(Input input) {
    // assert(
    //   decode('2333133121414131402').join() ==
    //       '00...111...2...333.44.5555.6666.777.888899',
    //   'Something went wrong',
    // );
    final decoded = decode(input.content);
    final compressed = compress(decoded.toList(growable: false));
    return checksum(compressed);
  }

  Iterable<Block> decode2(String diskMap) sync* {
    bool isBlock = true;
    int index = 0;
    for (final value in diskMap.split('')) {
      final length = int.parse(value);
      if (isBlock) {
        yield IntBlock(index, length: length);
        index++;
      } else {
        yield EmptyBlock(length: length);
      }
      isBlock = !isBlock;
    }
  }

  List<Block> compact(List<Block> sectors) {
    final last = sectors.whereType<IntBlock>().last;
    for (var i = last.value; i >= 0; i--) {
      final indexOfInt = sectors.indexWhere((e) {
        return e is IntBlock && e.value == i;
      });
      final integer = sectors[indexOfInt] as IntBlock;

      final indexValidEmpty = sectors.indexWhere((e) {
        return e is EmptyBlock && e.length >= integer.length;
      });
      if (indexValidEmpty == -1) continue;
      final empty = sectors[indexValidEmpty] as EmptyBlock;

      if (indexOfInt < indexValidEmpty) continue;

      if (empty.length == integer.length) {
        //
        sectors.swap(indexValidEmpty, indexOfInt);
      } else {
        // print(sectors.join());
        sectors[indexOfInt] = EmptyBlock(length: integer.length);
        sectors[indexValidEmpty] = EmptyBlock(
          length: empty.length - integer.length,
        );
        // test
        sectors.insert(indexValidEmpty, integer);
        // print(sectors.join());

        // debugger();
      }
    }
    return sectors;
  }

  @override
  part2(Input input) {
    final decoded = decode2(input.content).toList();
    // print(decoded.join());

    final compacted = compact(decoded);

    final expanded = compacted.expand<Part>((element) => switch (element) {
          EmptyBlock(:final length) => List.generate(length, (_) => Part.empty),
          IntBlock(:final length, :final value) =>
            List.generate(length, (_) => IntPart(value)),
        });
    // print(expanded.join());
    return checksum(expanded);
  }
}

// probably more efficient than having a million of the same class
// makes more sense as a block, where the other is fragmentary
sealed class Block {}

class EmptyBlock implements Block {
  const EmptyBlock({required this.length});
  final int length;
  @override
  String toString() => '.' * length;
}

class IntBlock implements Block {
  const IntBlock(this.value, {required this.length});
  final int value;
  final int length;
  @override
  String toString() => '$value' * length;
}
