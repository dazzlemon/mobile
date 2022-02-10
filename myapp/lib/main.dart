import 'package:flutter/material.dart';
import 'magic_square.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
		final magicSquaresList = magicSquares(3).toList();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
			home: ListView.separated(
				itemCount: magicSquaresList.length,
				separatorBuilder: (_, __) => const SizedBox(height: 16),
				itemBuilder: (_, int i) => MatrixView(magicSquaresList[i]),
			)
    );
  }
}

typedef Matrix<T> = Iterable<Iterable<T>>;

class MatrixView<T> extends StatelessWidget {
	final Matrix<T> matrix;
	const MatrixView(this.matrix, {Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context) =>
		Material(
			type: MaterialType.transparency,
			child: Table(
				children: matrix.map((row) =>
					TableRow(
						children: row.map((e) => TableCell(
							verticalAlignment: TableCellVerticalAlignment.middle,
							child: Container(
								child: Text(
									e.toString(),
									style: const TextStyle(
										color: Colors.black87
									)
								),
								color: Colors.white,
								alignment: Alignment.center
							)
						)).toList()
					)
				).toList(),
				border: TableBorder.symmetric(
						inside: BorderSide(width: 1, color: Colors.grey.shade800),
						outside: BorderSide.none
				),
			)
		);
}