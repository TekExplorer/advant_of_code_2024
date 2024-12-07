import 'dart:async';
import 'dart:convert';

import 'package:advent_of_code_2024/files.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

export 'package:fast_immutable_collections/fast_immutable_collections.dart';
export 'package:more/more.dart' hide IndexedIterableExtension;
export 'package:trotter/trotter.dart';

Future<void> ensureFilesExist() => (
      input.ensureExists(),
      output1.ensureExists(),
      output2.ensureExists(),
    ).wait;

extension SolveSolution on $Solution {
  Future<void> solve() async {
    await ensureFilesExist();

    final (p1, p2) = await (
      Future(part1),
      Future(part2),
    ).wait;

    await (
      output1.writeAsString(p1.toString()),
      output2.writeAsString(p2.toString()),
    ).wait;

    print('Part 1: $p1');
    print('Part 2: $p2');
  }

  IList<String> get lines => LineSplitter.split(contents).toIList();
  String get contents => inputContents;
}

abstract class $Solution {
  FutureOr<Object> part1();
  FutureOr<Object> part2();
}
