import 'dart:io';

import 'package:path/path.dart' show posix;

extension FileExists on File {
  Future<void> ensureExists() async {
    if (!await exists()) await create();
  }

  void ensureExistsSync() {
    if (!existsSync()) createSync();
  }
}

final _dir = posix.dirname(Platform.script.path);

final String _relativeDir = posix.relative(
  _dir,
  // move up two steps for useful stuff
  from: posix.dirname(posix.dirname(_dir)),
);

final $day = Directory(_relativeDir);

final input = $day.file('input.txt');

final inputContents = input.readAsStringSync();

final output1 = $day.file('output1.txt');
final output2 = $day.file('output2.txt');

final outputs = $day / 'outputs';

extension DirectoryExtensions on Directory {
  File file(String name) => File(posix.join(path, name));
  Directory operator /(String name) => Directory(posix.join(path, name));
}
