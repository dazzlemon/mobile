import 'package:lr1/matrix.dart';
import 'package:lr1/magic_square.dart';

void printUsage() {
	print('this app will print all magic squares of provided size');
	print('it can accept arguments >3, but it will take very long time to produce results');
	print('argument=2 wont produce any results because none exist');
}

void main(List<String> args) {
	if (args.length != 1) {
		print('wrong amount of arguments');
		printUsage();
	} else {
		var size = int.tryParse(args.first);
		if (size == 2) {
			print('no magic squares of size 2 exist');
		} else if (size != null) {
			magicSquares(size)
				.map(matrixToString)
				.forEach((m) => print(m + '\n'));
		} else {
			print('bad argument');
			printUsage();
		}
	}
}
