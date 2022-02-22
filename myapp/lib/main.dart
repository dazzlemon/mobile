import 'dart:ui';

import 'package:flutter/material.dart';
import 'magic_square.dart';
import 'matrix.dart';
import 'package:xrange/xrange.dart';
import 'package:worker_manager/worker_manager.dart';
import 'package:shimmer/shimmer.dart';

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

class MagicSquares extends StatefulWidget {
  const MagicSquares({Key? key}) : super(key: key);

	@override
	MagicSquaresState createState() => MagicSquaresState();
}

Future<List<Matrix<int>>> magicSquaresList(int size) => magicSquares(size).toList();

magicSquaresListView(List<Matrix<int>> magicSquares) =>
	ListView.separated(
		itemCount: magicSquares.length + 2,// one item in front and one at end
		separatorBuilder: (_, __) => const SizedBox(height: 32),
		itemBuilder: (_, int i) => i == 0 || i == magicSquares.length + 1 ? Container()
		                                                                  : Row(
			children: [SizedBox(
				child: MatrixView(magicSquares[i - 1]),
				height: magicSquares.length == 1 ? 64 : 32.0 * magicSquares.length,
				width:  magicSquares.length == 1 ? 64 : 32.0 * magicSquares.length,
			)],
			mainAxisAlignment: MainAxisAlignment.center
		)
	);

class MagicSquaresState extends State<MagicSquares> {
	int size = 3;
	Cancelable<List<Iterable<Iterable<int>>>>? task;

	@override
	Widget build(BuildContext context) {
		task?.cancel();
		task = Executor().execute(fun1: magicSquaresList, arg1: size);
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
						child: FutureBuilder<List<Matrix<int>>>(
							future: task,
							// future: compute(magicSquaresList, size),
							builder: (BuildContext context, AsyncSnapshot<List<Matrix<int>>> snapshot) {
								if (snapshot.connectionState == ConnectionState.waiting) {
									return Container(
										alignment: Alignment.topCenter,
										padding: const EdgeInsets.only(top: 32, left: 32, right: 32),
										child: AspectRatio(
											aspectRatio: 1,
											child: BlurryContainer(
												height: 64.0,
												width: double.infinity,
												child: Shimmer.fromColors(
													period: const Duration(milliseconds: 1000),
													baseColor: Colors.black.withOpacity(0.4),
													highlightColor: Colors.black.withOpacity(0.6),
													child: Container(
														alignment: Alignment.topCenter,
														child: AspectRatio(
															aspectRatio: 1,
															child: Container(
																height: 64.0,
																width: double.infinity,
																color: Colors.black,
															)
														)
													)
												)
											)
										)
									);
								}
								if (snapshot.hasError) {
									return const Text('There was an error :(');
								} else if (snapshot.hasData) {
									return Container(
										alignment: Alignment.center,
										padding: const EdgeInsets.only(left: 32, right: 32),
										// color: Colors.blueGrey.shade100,
										child: snapshot.data!.isNotEmpty ? magicSquaresListView(snapshot.data!)
										                                 : BlurryContainer(
											height: 64.0,
											width: double.infinity,
											bgColor: Colors.black.withOpacity(0.4),
											child: Container(
												alignment: Alignment.center,
												child: Text(
													'No magic squares of size $size',
													style: const TextStyle(
														color: Colors.white70,
													),
													textAlign: TextAlign.center,
												)
											)
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
					),
					floatingActionButton: IntSelect(1, 4, size, onChange: (i) => setState(() => size = i))
				)
			]
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
		selected = widget.selected;
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

const EdgeInsetsGeometry kPadding = EdgeInsets.zero;
const BorderRadius kBorderRadius = BorderRadius.all(Radius.circular(20));

class BlurryContainer extends StatelessWidget {
  final Widget? child;
  final double blur;
  final double height, width;
  final EdgeInsetsGeometry padding;
  final Color bgColor;

  final BorderRadius borderRadius;

  const BlurryContainer({
    Key? key,
    this.child,
    this.blur = 5,
    required this.height,
    required this.width,
    this.padding = kPadding,
    this.bgColor = Colors.transparent,
    this.borderRadius = kBorderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
    ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: height,
          width: width,
          padding: padding,
          color: bgColor,
          child: child,
        ),
      ),
    );
}

class MatrixView<T> extends StatelessWidget {
	final Matrix<T> matrix;
	const MatrixView(this.matrix, {Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context) =>
		AspectRatio(
			aspectRatio: 1,
			child: BlurryContainer(
				height: 32.0 * matrix.length,
				width: 32.0 * matrix.length,
				bgColor: Colors.black.withOpacity(0.4),
				child: Table(
					children: matrix.map((row) =>
						TableRow(
							children: row.map((e) => TableCell(
								verticalAlignment: TableCellVerticalAlignment.middle,
								child: AspectRatio(
									aspectRatio: 1,
									child: Container(
										height: 32,
										child: Text(
											e.toString(),
											style: const TextStyle(
												color: Colors.white70
											)
										),
										alignment: Alignment.center,
									)
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