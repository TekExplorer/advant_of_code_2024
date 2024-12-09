import 'package:advent_of_code_2024/grid.dart';
import 'package:test/test.dart';

const source = '''ABCD
EFGH
IJKL
MNOP
''';
void main() {
  test('Test grid', () {
    final grid = Grid.of(source);
    expect(grid.source, source);
    expect(grid.get((x: -1, y: 0)), Char.empty);
    expect(grid.get((x: 0, y: 0)), Char('A'));
    expect(grid.get((x: 1, y: 0)), Char('B'));
    expect(grid.get((x: 2, y: 0)), Char('C'));
    expect(grid.get((x: 3, y: 0)), Char('D'));
    expect(grid.get((x: 4, y: 0)), Char.empty);

    //
    expect(grid.get((x: 0, y: -1)), Char.empty);
    expect(grid.get((x: 0, y: 0)), Char('A'));
    expect(grid.get((x: 0, y: 1)), Char('E'));
    expect(grid.get((x: 0, y: 2)), Char('I'));
    expect(grid.get((x: 0, y: 3)), Char('M'));
    expect(grid.get((x: 0, y: 4)), Char.empty);

    //
    grid.set((x: 0, y: 0), Char('Z'));
    expect(grid.get((x: 0, y: 0)), Char('Z'));
  });
  test('Test line', () {
    final grid = Grid.of(source);
    final line = grid.lineAt(2);
    expect(grid[(x: 3, y: 2)], Char('L'));
    expect(line[3], Char('L'));
    line[3] = Char('Z');
    expect(line[3], Char('Z'));
    expect(grid[(x: 3, y: 2)], Char('Z'));
  });
}
