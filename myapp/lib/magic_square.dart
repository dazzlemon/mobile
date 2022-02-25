import 'package:xrange/xrange.dart';

Stream<List<int>> permutations(int size) =>
	permutations_(integers(1, size + 1));

Stream<List<int>> permutations_(Iterable<int> list) async* {
	var factorials = <int>[];
	factorials.add(1);
	var i = 0;
	for (i = 1; i <= list.length; i++) {
		factorials.add(factorials[i - 1] * i);
	}

	var onePermutation = <int>[];
	var temp = <int>[];
	var positionCode = 0;
	var selected = 0;
	var position = 0;
	for (i = 0; i < factorials[list.length]; i++) {
		onePermutation.clear();
		temp.clear();
		temp.addAll(list);
		positionCode = i;
		for (position = list.length; position > 0; position--) {
			selected     = positionCode ~/ factorials[position - 1];
			positionCode = positionCode % factorials[position - 1];
			onePermutation.add(temp[selected]);
			temp.removeAt(selected);
		}
		yield [...onePermutation];
	}
}

bool isMagicSquare(List<int> matrix, int size) {
	print(matrix);
	var diagSum1 = 0;
	var diagSum2 = 0;
	var magicConst = size * (size * size + 1) / 2;
	var rowSum = 0;
	var colSum = 0;
	var i = 0;
	var j = 0;
	for (i = 0; i < size; i++) {
		rowSum = 0;
		colSum = 0;
		for (j = 0; j < size; j++) {
			rowSum += matrix[j * size + i];
			colSum += matrix[i * size + j];
		}
		if (rowSum != magicConst || colSum != magicConst) {
			return false;
		}
		diagSum1 += matrix[             i * size + i];
		diagSum2 += matrix[(size - 1 - i) * size + i];
	}
	if (diagSum1 != magicConst || diagSum2 != magicConst) {
		return false;
	}
	return true;
}

Stream<List<int>> magicSquares(int size) =>
	permutations(size * size)
		.where((p) => isMagicSquare(p, size));
