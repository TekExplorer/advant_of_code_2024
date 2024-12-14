import 'dart:convert';

import 'package:advent_of_code_2024/advent_of_code_2024.dart';
import 'package:advent_of_code_2024/files.dart';
import 'package:advent_of_code_2024/grid.dart';

class Input {
  late final String content = inputContents;
  late final IList<String> lines = input.readAsLinesSync().lock;
  Stream<String> get linesStream =>
      input.openRead().map(utf8.decode).transform(LineSplitter());
  // possibly add more methods

  Grid get grid => Grid.of(content);

  bool get isExample => false;
}

class ExampleInput implements Input {
  ExampleInput(this.content);

  @override
  final String content;

  @override
  late IList<String> lines = LineSplitter.split(content).toIList();

  @override
  Stream<String> get linesStream =>
      Stream.fromIterable(LineSplitter.split(content));
  @override
  Grid get grid => Grid.of(content);
  @override
  bool get isExample => true;
}
