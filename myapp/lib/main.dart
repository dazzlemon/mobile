import 'dart:ui';

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
			body: Container(
				decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
				child: SafeArea(
					child: FutureBuilder<List<Matrix<int>>>(
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
									padding: const EdgeInsets.only(left: 32, right: 32),
									// color: Colors.blueGrey.shade100,
									child: snapshot.data!.isEmpty ? Text('No magic squares of size $size') : ListView.separated(
										itemCount: snapshot.data!.length,
										separatorBuilder: (_, __) => const SizedBox(
											height: 32,
										),
										itemBuilder: (_, int i) => MatrixView(snapshot.data![i]),
									)
								);
							} else {
								return const AspectRatio(
									aspectRatio: 1,
									child: CircularProgressIndicator(color: Colors.pinkAccent)
								);
							}
						},
					)
				)
			),
			floatingActionButton: IntSelect(1, 4, size, onChange: (i) => setState(() => size = i))
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
					if (newValue != null && newValue != selected) {
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

const EdgeInsetsGeometry kPadding = EdgeInsets.all(5);
const BorderRadius kBorderRadius = BorderRadius.all(Radius.circular(5));

class BlurryContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double? height, width;
  final EdgeInsetsGeometry padding;
  final Color bgColor;

  final BorderRadius borderRadius;

  //final double colorOpacity;

  const BlurryContainer({
    Key? key,
    required this.child,
    this.blur = 5,
    required this.height,
    required this.width,
    this.padding = kPadding,
    this.bgColor = Colors.transparent,
    this.borderRadius = kBorderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: height!,
          width: width!,
          padding: padding,
          color: bgColor,
          child: child,
        ),
      ),
    );
  }
}

class MatrixView<T> extends StatelessWidget {
	final Matrix<T> matrix;
	const MatrixView(this.matrix, {Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context) =>
		BlurryContainer(
			height: 64.0 * matrix.length,
			width: 60,
			bgColor: Colors.black.withOpacity(0.4),
			borderRadius: BorderRadius.circular(5),
			child: Table(
				children: matrix.map((row) =>
					TableRow(
						children: row.map((e) => TableCell(
							verticalAlignment: TableCellVerticalAlignment.middle,
							child: Container(
								height: 64,
								child: Text(
									e.toString(),
									style: const TextStyle(
										color: Colors.white70
									)
								),
								// color: Colors.white,
								alignment: Alignment.center,
							)
						)).toList()
					)
				).toList(),
				border: TableBorder.symmetric(
						inside: const BorderSide(width: 1, color: Colors.white30),
						outside: BorderSide.none
				),
				)
		);
}