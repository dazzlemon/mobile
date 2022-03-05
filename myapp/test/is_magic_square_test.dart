import 'package:flutter_test/flutter_test.dart';
import 'package:magic_squares/magic_square.dart';

void main() {
	test('isMagicSquare 4x4 true#1', () =>
		expect(
			isMagicSquare(
				[
					 2, 16, 13,  3,
					11,  5,  8, 10,
					 7,  9, 12,  6,
					14,  4,  1, 15,
				],
				4
			),
			equals(true)
		)
	);
	test('isMagicSquare 4x4 true#2', () =>
		expect(
			isMagicSquare(
				[
					 1, 15, 14,  4,
					10, 11,  8,  5,
					 7,  6,  9, 12,
					16,  2,  3, 13,
				],
				4
			),
			equals(true)
		)
	);	
}