import 'dart:async';
import 'dart:io';

import "package:path/path.dart" show posix;

extension on Future<String> {
  Future<String> stringifyError() => onError((e, _) => e.toString());
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

extension SolveSolution on $Solution {
  Future<void> solve() async {
    await (
      output1.writeAsString(await Future(part1).stringifyError()),
      output2.writeAsString(await Future(part2).stringifyError()),
    ).wait;
  }
}

abstract class $Solution {
  FutureOr<String> part1();
  FutureOr<String> part2();
}
