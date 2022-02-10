import 'package:collection/collection.dart';
import 'package:xrange/xrange.dart';
import 'package:list_ext/list_ext.dart' hide IntIterableExtensions;
import 'matrix.dart';
import 'permutations.dart';

Matrix<T> transpose<T>(Matrix<T> matrix) {
	if (matrix.isEmpty) {
		return matrix;
	}
	if (matrix.any((row) => row.length != matrix.length)) {
		throw StateError('Not a matrix');
	}
	if (matrix.first.isEmpty) {
		throw StateError('Degenerate matrix');
	}
	int nRows = matrix.length;
	int nCols = matrix.first.length;

	return List.generate(
		nCols,
		(i) => List.generate(
			nRows, 
			(j) => matrix.elementAt(j).elementAt(i)
		)
	);
}

bool isMagicSquare(Matrix<int> matrix) {
	if (matrix.length == 2
		|| matrix.any((row) => row.length != matrix.length)
	) {
		return false;
	}
	// print('testing' + matrix.toString());

	var magicConst = matrix.length * (matrix.length * matrix.length + 1) / 2;
	return !(
		// check rows
		matrix.any((row) => row.sum != magicConst)
		// check cols
		|| transpose(matrix).any((col) => col.sum != magicConst)
		// check main diag
		|| integers(0, matrix.length)
			.map((i) => matrix.elementAt(i).elementAt(i))
			.sum != magicConst
		// check secondaryDiag
		|| integers(0, matrix.length)
			.map((i) => matrix.elementAt(i).elementAt(matrix.length - 1 - i))
			.sum != magicConst
	);
}

Iterable<Matrix<int>> magicSquares(int size) =>
	permutations(size * size)
		.map((p) => p.chunks(size).toList())
		.where(isMagicSquare);