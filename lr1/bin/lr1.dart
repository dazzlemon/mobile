import 'package:lr1/matrix.dart';
import 'package:lr1/magic_square.dart';

void main(List<String> arguments) {
	var size = 3;
	magicSquares(size)
		.map(matrixToString)
		.forEach((m) => print(m + '\n'));
}