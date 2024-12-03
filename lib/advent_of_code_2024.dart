import 'dart:async';
import 'dart:io';

import "package:path/path.dart" show posix;

extension on Future<String> {
  Future<Result> wrapError() => then<Result>(Ok.new).onError(Err.new);
}

final dir = posix.dirname(Platform.script.path);
final relativeDir = posix.relative(
  dir,
  // move up two steps for useful stuff
  from: posix.dirname(posix.dirname(dir)),
);

final input = File(posix.join(relativeDir, 'input.txt'));
final output1 = File(posix.join(relativeDir, 'output1.txt'));
final output2 = File(posix.join(relativeDir, 'output2.txt'));

sealed class Result {}

class Ok implements Result {
  Ok(this.value);
  final String value;

  @override
  String toString() => value;
}

class Err implements Result {
  Err(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() {
    if (error is UnimplementedError) return 'unimplemented';
    return error.toString();
  }
}

extension on File {
  Future<void> ensureExists() async {
    if (!await exists()) await create();
  }
}

extension SolveSolution on $Solution {
  Future<void> ensureFilesExist() => (
        input.ensureExists(),
        output1.ensureExists(),
        output2.ensureExists(),
      ).wait;

  Future<(Result part1, Result part2)> solve() async {
    await ensureFilesExist();

    final (p1, p2) = await (
      Future(part1).wrapError(),
      Future(part2).wrapError(),
    ).wait;

    await (
      output1.writeAsString(p1.toString()),
      output2.writeAsString(p2.toString()),
    ).wait;

    print('Part 1: $p1');
    print('Part 2: $p2');

    return (p1, p2);
  }
}

abstract class $Solution {
  FutureOr<String> part1();
  FutureOr<String> part2();
}
