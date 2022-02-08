import 'package:collection/collection.dart';
import 'package:xrange/xrange.dart';

List<List<T>> transpose<T>(List<List<T>> matrix) {
	if (matrix.isEmpty) {
		return matrix;
	}
	if (matrix.any((row) => row.length != matrix.length)) {
		throw StateError('Not a matrix');
	}
	if (matrix[0].isEmpty) {
		throw StateError('Degenerate matrix');
	}
	int nRows = matrix.length;
	int nCols = matrix[0].length;

	return List.generate(
		nCols,
		(i) => List.generate(
			nRows, 
			(j) => matrix[j][i]
		)
	);
}

bool isMagicSquare(List<List<int>> matrix) {
	if (matrix.length == 2
		|| matrix.any((row) => row.length != matrix.length)
	) {
		return false;
	}

	var magicConst = matrix.length * (matrix.length * matrix.length + 1) / 2;
	return !(
		// check rows
		matrix.any((row) => row.sum != magicConst)
		// check cols
		|| transpose(matrix).any((col) => col.sum != magicConst)
		// check main diag
		|| integers(0, matrix.length)
			.map((i) => matrix[i][i])
			.sum != magicConst
		// check secondaryDiag
		|| integers(0, matrix.length)
			.map((i) => matrix[i][matrix.length - 1 - i])
			.sum != magicConst
	);
}