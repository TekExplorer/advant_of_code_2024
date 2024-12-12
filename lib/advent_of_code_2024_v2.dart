import 'dart:async';

import 'package:advent_of_code_2024/files.dart';

import 'input.dart';

export 'package:fast_immutable_collections/fast_immutable_collections.dart';
export 'package:more/more.dart' hide IndexedIterableExtension;
export 'package:trotter/trotter.dart';

export 'input.dart';

abstract class $Solution {
  Example get example;

  FutureOr<Object> part1(Input input);
  FutureOr<Object> part2(Input input);
}

extension type const Example.raw(
    ({String contents, Object part1, Object part2}) _) {
  Example(
    String contents, {
    required Object part1,
    required Object part2,
  }) : _ = (
          contents: contents,
          part1: part1,
          part2: part2,
        );

  Input get contents => ExampleInput(_.contents);
  Object get part1 => _.part1;
  Object get part2 => _.part2;
}

extension SolveSolution on $Solution {
  Future<void> solve() async {
    await input.ensureExists();
    await solveExample();
    await solveActual();
  }

  Future<void> solveExample() async {
    final input = example.contents;
    final (p1, p2) = await (
      Future(() => part1(input)).onError<Object>((e, __) => e),
      Future(() => part2(input)).onError<Object>((e, __) => e),
    ).wait;
    final (p1a, p2a) = (example.part1, example.part2);
    print('Example');
    if ('$p1a' == '$p1') {
      print('\tPart 1 Success! $p1');
    } else {
      print('\tPart 1 Failure! $p1 should be `$p1a`');
    }

    if ('$p2a' == '$p2') {
      print('\tPart 2 Success! $p2');
    } else {
      print('\tPart 2 Failure! $p2 should be `$p2a`');
    }
  }

  Future<void> solveActual() async {
    final input = Input();
    if (input.content.isEmpty) return;
    final (p1, p2) = await (
      Future(() => part1(input)).onError<Object>((e, __) => e),
      Future(() => part2(input)).onError<Object>((e, __) => e),
    ).wait;
    print('Solution');
    print('\tPart 1: $p1');
    print('\tPart 2: $p2');
  }
}

extension MapKV<K, V> on Map<K, V> {
  Iterable<(K, V)> get kv => entries.map((e) => (e.key, e.value));
}
