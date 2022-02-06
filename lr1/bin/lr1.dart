import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';
// import supercharged dart

List<List<T>> makeMatrix<T>(int rows, int cols, T fill) =>
	List<List<T>>.filled(
		rows,
		List<T>.filled(cols, fill)
	);

String _toString(element) => element.toString();

void printMatrix<T>(List<List<T>> matrix, {
  String elementDelimiter=' ',
  String rowDelimiter='\n',
  String rowPrefix='',
  String rowSuffix='',
  String Function(T) elementToString=_toString
}) {
  var stringElements = matrix.map((row) =>
    row.map((e) => elementToString(e))
  );
  var maxWidth = stringElements.flattened.map((s) => s.length).max();

  String alignedElement(String s) =>
    ' ' * (maxWidth - s.length) + s;

  void printRow(List<String> row) {
    stdout.write(rowPrefix);
    row.withoutLast.forEach((element) =>
      stdout.write(alignedElement(element) + elementDelimiter)
    );
    stdout.write(alignedElement(row.last) + rowSuffix + rowDelimiter);
  }

  stringElements.withoutLast.forEach(printRow);
  printRow(stringElements.last);
}

void main(List<String> arguments) {
  var matrix = makeMatrix(3, 3, 0);
  var r = Random();
  for (var i in 0.until(3)) {
    for (var j in 0.until(3)) {
      matrix[i][j] = r.nextInt(10000000) - 5000000;
    } 
  } 
  printMatrix(matrix, elementDelimiter: ' | ');
}
