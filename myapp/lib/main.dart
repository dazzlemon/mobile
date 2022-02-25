import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:list_ext/list_ext.dart';
import 'magic_square.dart';
import 'package:xrange/xrange.dart';
import 'util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
    MaterialApp(
      title: 'Magic Squares',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
			home: const MagicSquares()
		);
}

ListView magicSquaresListView(List<List<int>> magicSquares, int size, {bool loading = false}) {
	double cellSize = 64;
	return listViewWithOutsideSeparators(
		[
			...magicSquares.map((m) => Container(
				alignment: Alignment.center,
				child: squareBox(
					MatrixView(m, cellSize),
					cellSize * size
				),
			)),
			if (loading) frostedGlassShimmer(Size.square(cellSize * size))
		],
		(_, __) => const SizedBox(height: 32),
	);
}

SizedBox squareBox(Widget child, double size) =>
	SizedBox(child: child, width: size, height: size);

class IsolateInit {
	final SendPort sendPort;
	final int size;
	IsolateInit(this.sendPort, this.size);
}

Future<void> magicSquaresIsolate(IsolateInit init) async {
	await for (final magicSquare in magicSquares(init.size)) {
		init.sendPort.send(magicSquare);
	}
}

class MagicSquares extends HookWidget {
  const MagicSquares({Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		final size = useState(1);
		final list = useState(<List<int>>[]);
		final loading = useState(true);

		final isolate = useState<Isolate?>(null);
		final receivePort = useState<ReceivePort?>(null);
		final exitPort = useState<ReceivePort?>(null);

		void startIsolate() async {
			print('startIsolate');
			list.value = [];
			loading.value = true;
			receivePort.value = ReceivePort();
			exitPort.value = ReceivePort();
			isolate.value = await Isolate.spawn(
				magicSquaresIsolate,
				IsolateInit(
					receivePort.value!.sendPort,
					size.value
				),
				onExit: exitPort.value!.sendPort
			);
			receivePort.value!.listen((msg) => list.value = [...list.value, msg]);
			exitPort.value!.listen((msg) => loading.value = false);
		}

		void stopIsolate() {
			print('stopIsolate');
			isolate.value?.kill();
			receivePort.value?.close();
			exitPort.value?.close();
		}

		useEffect(() {
			print('useEffect');
			startIsolate();
		}, []);

		return Stack(
			children: [
				Container(
					decoration: const BoxDecoration(
						image: DecorationImage(
							image: AssetImage("assets/bg.jpg"),
							fit: BoxFit.cover
						)
					)
    		),
				Scaffold(
					backgroundColor: Colors.transparent,
					body: SafeArea(
						child: Container(
							padding: const EdgeInsets.only(left: 32, right: 32),
							child: loading.value || list.value.isNotEmpty
								? magicSquaresListView(list.value, size.value, loading: loading.value)
								: Container(
									alignment: Alignment.center,
									child: noMagicSquares(size.value),
									height: double.infinity
								)
						)
					),
					floatingActionButton: IntSelect(1, 4, size.value, onChange: (i) {
						size.value = i;
						stopIsolate();
						startIsolate();
					})
				)
			]
		);
	}
}

class IntSelect extends HookWidget {
	final int min;
	final int max;
	final int selected;
	final Function(int)? onChange;
	const IntSelect(this.min, this.max, this.selected, {Key? key, this.onChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
		final selected_ = useState(selected);
		return DropdownButton<int>(
      value: selected_.value,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (int? newValue) {
				if (newValue != null && newValue != selected) {
					selected_.value = newValue;
					onChange?.call(newValue);
				}
			},
      items: integers(min, max + 1)
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
	final List<T> matrix;
	final double cellSize;
	const MatrixView(this.matrix, this.cellSize, {Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context) =>
		AspectRatio(
			aspectRatio: 1,
			child: BlurryContainer(
				size: Size.square(cellSize * matrix.length),
				bgColor: Colors.black.withOpacity(0.4),
				child: Table(
					children: matrix.chunks(sqrt(matrix.length).toInt()).map((row) =>
						TableRow(
							children: row.map((e) => TableCell(
								verticalAlignment: TableCellVerticalAlignment.middle,
								child: squareBox(
									Center(
										child: Text(
											e.toString(),
											style: const TextStyle(
												color: Colors.white70
											)
										)
									),
									cellSize
								)
							)).toList()
						)
					).toList(),
					border: TableBorder.symmetric(
							inside: const BorderSide(width: 1, color: Colors.white30),
							outside: BorderSide.none
					),
				)
			)
		);
}