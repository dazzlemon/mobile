import 'package:lr1/matrix.dart';
import 'package:lr1/permutations.dart';
import 'package:lr1/magic_square.dart';
import 'package:list_ext/list_ext.dart';

void main(List<String> arguments) {
  var size = 3;
  permutations(size * size)
    .map((p) => p.chunks(size).toList())
    .where(isMagicSquare)
    .map(matrixToString)
    .forEach((m) => print(m + '\n'));
}