import 'package:flutter/material.dart';
import 'magic_square.dart';
import 'matrix.dart';
import 'package:xrange/xrange.dart';
import 'package:worker_manager/worker_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
			home: const MagicSquares()
    );
}

class MagicSquares extends StatefulWidget {
  const MagicSquares({Key? key}) : super(key: key);

	@override
	MagicSquaresState createState() => MagicSquaresState();
}

List<Matrix<int>> magicSquaresList(int size) => magicSquares(size).toList();

class MagicSquaresState extends State<MagicSquares> {
	int size = 3;
	Cancelable<List<Iterable<Iterable<int>>>>? task;

	@override
	Widget build(BuildContext context) {
		task?.cancel();
		task = Executor().execute(fun1: magicSquaresList, arg1: size);
		return Scaffold(
			body: FutureBuilder<List<Matrix<int>>>(
				future: task,
				// future: compute(magicSquaresList, size),
				builder: (BuildContext context, AsyncSnapshot<List<Matrix<int>>> snapshot) {
					if (snapshot.connectionState == ConnectionState.waiting) {
						return const AspectRatio(
						  aspectRatio: 1,
						  child: CircularProgressIndicator(color: Colors.pinkAccent)
						);
					}
					if (snapshot.hasError) {
						return const Text('There was an error :(');
					} else if (snapshot.hasData) {
						return Container(
							color: Colors.blueGrey.shade100,
							child: ListView.separated(
								itemCount: snapshot.data!.length,
								separatorBuilder: (_, __) => const SizedBox(
									height: 16,
								),
								itemBuilder: (_, int i) => MatrixView(snapshot.data![i]),
							)
						);
          } else {
            return const SizedBox(
							width: double.infinity,
							child: CircularProgressIndicator(color: Colors.pinkAccent),
						);
          }
				},
			),
			// Container(
				// color: Colors.blueGrey.shade100,
				// child: ListView.separated(
					// itemCount: magicSquaresList.length,
					// separatorBuilder: (_, __) => const SizedBox(
						// height: 16,
					// ),
					// itemBuilder: (_, int i) => MatrixView(magicSquaresList[i]),
				// )
			// ),
			floatingActionButton: IntSelect(1, 4, size, onChange: (i) => setState(() {
				size = i;
			}))
		);

	}
}

class IntSelect extends StatefulWidget {
	final int min;
	final int max;
	final int selected;
	final Function(int)? onChange;
	const IntSelect(this.min, this.max, this.selected, {Key? key, this.onChange}) : super(key: key);

  @override
  State<IntSelect> createState() => IntSelectState();
}

class IntSelectState extends State<IntSelect> {
	late int selected;
	@override
	void initState() {
		super.initState();
		selected = widget.min;
	}

  @override
  Widget build(BuildContext context) {
		return DropdownButton<int>(
      value: selected,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (int? newValue) {
        setState(() {
					if (newValue != null) {
          	selected = newValue;
						widget.onChange?.call(newValue);
					}
				});
      },
      items: integers(widget.min, widget.max + 1)
        .map((i) =>
					DropdownMenuItem<int>(
						value: i,
						child: Text(i.toString()),
					)
      ).toList(),
    );
  }
}

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