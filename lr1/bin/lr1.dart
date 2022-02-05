import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';

List<List<T>> makeMatrix<T>(int rows, int cols, T fill) =>
	Iterable<List<T>>.generate(
		rows,
		(_) => List<T>.filled(cols, fill)
	).toList();

String _toString(element) => element.toString();

void printMatrix<T>(List<List<T>> matrix, {
  String elementDelimiter=' ',
  String rowDelimiter='\n',
  String rowPrefix='',
  String rowSuffix='',
  String Function(T) elementToString=_toString
}) {
  var stringElements = matrix.map((row) =>
    row.map((e) => elementToString(e)).toList()
  ).toList();
  var maxWidth = stringElements.flattened.map((s) => s.length).reduce(max);

  String alignedElement(String s) =>
    ' ' * (maxWidth - s.length) + s;

  void printRow(List<String> row) {
    stdout.write(rowPrefix);
    row.take(row.length - 1).forEach((element) =>
      stdout.write(alignedElement(element) + elementDelimiter)
    );
    stdout.write(alignedElement(row.last) + rowSuffix + rowDelimiter);
  }

  stringElements.take(matrix.length - 1).forEach(printRow);
  printRow(stringElements.last);
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
}
