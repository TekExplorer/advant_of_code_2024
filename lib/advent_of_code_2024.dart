import 'dart:async';
import 'dart:io';

import "package:path/path.dart" show posix;

extension on Future<String> {
  Future<_Result> wrapError() => then<_Result>(_Ok.new).onError(_Err.new);
}

final _dir = posix.dirname(Platform.script.path);
final _relativeDir = posix.relative(
  _dir,
  // move up two steps for useful stuff
  from: posix.dirname(posix.dirname(_dir)),
);

final _input = File(posix.join(_relativeDir, 'input.txt'));
final _lines = _input.readAsLinesSync();
final _contents = _input.readAsStringSync();

final _output1 = File(posix.join(_relativeDir, 'output1.txt'));
final _output2 = File(posix.join(_relativeDir, 'output2.txt'));

sealed class _Result {}

class _Ok implements _Result {
  _Ok(this.value);
  final String value;

  @override
  String toString() => value;
}

class _Err implements _Result {
  _Err(this.error, this.stackTrace);

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
        _input.ensureExists(),
        _output1.ensureExists(),
        _output2.ensureExists(),
      ).wait;

  Future<(_Result part1, _Result part2)> solve() async {
    await ensureFilesExist();

    final (p1, p2) = await (
      Future(part1).wrapError(),
      Future(part2).wrapError(),
    ).wait;

    await (
      _output1.writeAsString(p1.toString()),
      _output2.writeAsString(p2.toString()),
    ).wait;

    print('Part 1: $p1');
    print('Part 2: $p2');

    return (p1, p2);
  }

  List<String> get lines => _lines;
  String get contents => _contents;
}

abstract class $Solution {
  FutureOr<String> part1();
  FutureOr<String> part2();
}
