import 'dart:convert';
import 'dart:typed_data';

typedef XY = ({int x, int y});

extension type const Char._(String char) {
  static const empty = Char._('');
  static const dot = Char._('.');

  factory Char(String char) {
    if (char.length != 1) {
      throw ArgumentError.value(char, 'char', 'Should be a character');
    }
    return Char._(char);
  }

  factory Char.decode(int encoded) => Char(ascii.decode([encoded]));

  bool get isEmpty => char.isEmpty;
  bool get isDot => this == dot;

  int? toInt() => int.tryParse(char);
}

extension CharASCIIEncoder on Char {
  int encode() {
    if (isEmpty) throw UnsupportedError('this Char is empty');
    return ascii.encode(char).single;
  }
}

class Grid {
  factory Grid.of(String source) {
    final split = LineSplitter.split(source.trim());
    final bytes = ascii.encode(split.join());
    if (bytes.length != split.join().length) {
      throw StateError('ascii encoding error');
    }
    final width = split.first.length;
    final height = split.length;
    if (width * height != split.join().length) {
      throw StateError('uneven lines');
    }
    return Grid._(bytes, width);
  }
  Grid._(this._grid, this.width);
  final Uint8List _grid;
  final int width;
  late final int height = _grid.length ~/ width;

  int _indexOf(XY pos) {
    final dxForY = pos.y * width;
    return dxForY + pos.x;
  }

  XY _posOfIndex(int index) {
    final y = index ~/ width;
    final x = index % width;
    return (x: x, y: y);
  }

  XY? posOf(Char char) {
    final index = _grid.indexOf(char.encode());
    if (index == -1) return null;
    return _posOfIndex(index);
  }

  Iterable<XY> allPosOf(Char char) sync* {
    for (var i = 0; i < _grid.length; i++) {
      if (Char.decode(_grid[i]) == char) {
        yield _posOfIndex(i);
      }
    }
  }

  bool _isValidPos(XY pos) {
    if (pos.x >= width || pos.y >= height || pos.x < 0 || pos.y < 0) {
      return false;
    }
    return true;
  }

  Char operator [](XY pos) => get(pos);
  Char get(XY pos) {
    if (!_isValidPos(pos)) return Char.empty;
    return Char.decode(_grid[_indexOf(pos)]);
  }

  void operator []=(XY pos, Char char) => set(pos, char);
  void set(XY pos, Char char) {
    if (!_isValidPos(pos)) {
      throw RangeError('Out of range: $pos, width: $width, height: $height');
    }
    _grid[_indexOf(pos)] = char.encode();
  }

  Line lineAt(int y) {
    final dxForY = y * width;
    return Line(Uint8List.sublistView(_grid, dxForY, dxForY + width));
  }

  Iterable<Line> get lines sync* {
    for (var i = 0; i < height; i++) {
      yield lineAt(i);
    }
  }

  @override
  String toString() => source;
  String get source {
    final buffer = StringBuffer();
    for (final line in lines) {
      for (final char in line.chars) {
        buffer.write(char);
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  Iterable<XY> get positions sync* {
    // for (final y in Iterable<int>.generate(height)) {
    //   for (final x in Iterable<int>.generate(width)) {
    //     yield (x: x, y: y);
    //   }
    // }
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        yield (x: x, y: y);
      }
    }
  }

  Grid clone() => Grid._(Uint8List.fromList(_grid), width);
  void setAllRaw(Iterable<int> raw) {
    if (raw.length != _grid.length) {
      throw ArgumentError('raw must have the same length as the grid');
    }
    _grid.setAll(0, raw);
  }

  void setFrom(Grid other) => setAllRaw(other._grid);
}

extension type Line(Uint8List _line) {
  int get length => _line.length;

  Iterable<Char> get chars sync* {
    for (var i = 0; i < length; i++) {
      yield get(i);
    }
  }

  String decode() => ascii.decode(_line);

  Char operator [](int pos) => get(pos);
  Char get(int pos) {
    if (pos > _line.length || pos < 0) return Char.empty;
    return Char.decode(_line[pos]);
  }

  void operator []=(int pos, Char char) => set(pos, char);
  void set(int pos, Char char) {
    if (pos > _line.length || pos < 0) {
      throw RangeError('Out of range: $pos, width: $length');
    }
    _line[pos] = char.encode();
  }
}
