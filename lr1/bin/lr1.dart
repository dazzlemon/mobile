import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:list_ext/list_ext.dart';

List<List<T>> makeMatrix<T>(int rows, int cols, T fill) =>
	List<List<T>>.generate(
		rows,
		(i) => List<T>.filled(cols, fill)
	);

String _toString(element) => element.toString();

void printMatrix<T>(List<List<T>> matrix, {
  String elementDelimiter=' ',
  // elementAlignment = Left
  //                                    | Right
  //                                    | Center
  //                                    | None
  String rowDelimiter='\n',
  String rowPrefix='',
  String rowSuffix='',
  String Function(T) elementToString=_toString
}) {
  var stringElements = matrix
    .map((row) => row
      .map((e) => elementToString(e)));
  var maxWidth = stringElements
    .flattened
    .map((s) => s.length)
    .max();

  String alignedElement(String s) =>
    s.padLeft(maxWidth, ' ');

  String rowToString(Iterable<String> row)
    => rowPrefix
    +   row.map(alignedElement)
              .join(elementDelimiter)
    +   rowSuffix;

  stdout.write(stringElements
    .map(rowToString)
    .join(rowDelimiter));
}

void main(List<String> arguments) {
  var matrix = makeMatrix(3, 3, 0);
  var r = Random();
  for (var i = 0; i < 3; i++) {
    for (var j = 0; j < 3; j++) {
      matrix[i][j] = r.nextInt(10000000) - 5000000;
    }
  }
  printMatrix(matrix, elementDelimiter: ' | ');
  print('');
}
