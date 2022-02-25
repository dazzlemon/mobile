import 'package:list_ext/src/interable_extensions.dart';
import 'package:xrange/xrange.dart';

Stream<Iterable<int>> permutations(int size) =>
	permutations_(integers(1, size + 1));

Stream<Iterable<int>> permutations_(Iterable<int> list) async* {
	var factorials = <int>[];
	factorials.add(1);
	for (var i = 1; i <= list.length; i++) {
		factorials.add(factorials[i - 1] * i);
	}

	for (var i = 0; i < factorials[list.length]; i++) {
		var onePermutation = <int>[];
		var temp = list.toList();
		var positionCode = i;
		for (var position = list.length; position > 0; position--) {
			var selected = positionCode ~/ factorials[position - 1];
			onePermutation.add(temp.elementAt(selected));
			positionCode = positionCode % factorials[position - 1];
			temp = temp.sublist(0, selected) + temp.sublist(selected + 1);
		}
		yield onePermutation;
	}
}

bool isMagicSquare(Iterable<int> matrix, int size) {
	var diagSum1 = 0;
	var diagSum2 = 0;
	var magicConst = size * (size * size + 1) / 2;
	for (var i = 0; i < size; i++) {
		var rowSum = 0;
		var colSum = 0;
		for (var j = 0; j < size; j++) {
			rowSum += matrix.elementAt(j * size + i);
			colSum += matrix.elementAt(i * size + j);
		}
		if (rowSum != magicConst || colSum != magicConst) {
			return false;
		}
		diagSum1 += matrix.elementAt(i * size + i);
		diagSum2 += matrix.elementAt((size - 1 - i) * size + i);
	}
	if (diagSum1 != magicConst || diagSum2 != magicConst) {
		return false;
	}
	return true;
}

Stream<Iterable<int>> magicSquares(int size) =>
	permutations(size * size)
		.where((p) => isMagicSquare(p, size));