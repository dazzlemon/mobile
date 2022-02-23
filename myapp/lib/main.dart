import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'magic_square.dart';
import 'matrix.dart';
import 'package:xrange/xrange.dart';
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

ListView listViewWithOutsideSeparators(Iterable<Widget>children, Widget Function(BuildContext, int) separatorBuilder) {
	var items = [Container(), ...children, Container()];
	return 	ListView.separated(
		itemBuilder: (_, i) => items.elementAt(i),
		separatorBuilder: separatorBuilder,
		itemCount: items.length
	);
}

ListView magicSquaresListView(List<Matrix<int>> magicSquares, int size, {bool loading = false}) {
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
			if (loading) loadingMatrix(cellSize * size)
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

class MagicSquaresState extends State<MagicSquares> {
	int size = 3;
	late Isolate isolate;
	List<Matrix<int>> list = [];
	bool loading = true;

	@override
  void initState() {
    super.initState();
		startNewIsolate();
  }

	@override
  void dispose() {
    super.dispose();
		isolate.kill();
  }

	void startNewIsolate() async {
		loading = true;
		list = [];
		var receivePort = ReceivePort();
		var exitPort = ReceivePort();
		var initMsg = IsolateInit(
			receivePort.sendPort,
			size
		);
		isolate = await Isolate.spawn(magicSquaresIsolate, initMsg, onExit: exitPort.sendPort);
		receivePort.listen((msg) =>
			setState(() {
				list.add(msg);
			})
		);
		exitPort.listen((msg) =>
			setState(() => loading = false)
		);
	}

	@override
	Widget build(BuildContext context) {
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
							child: loading || list.isNotEmpty
								? magicSquaresListView(list, size, loading: loading)
								: Container(
									alignment: Alignment.center,
									child: noMagicSquares(size),
									height: double.infinity
								)
						)
					),
					floatingActionButton: IntSelect(1, 4, size, onChange: (i) => setState(() {
						size = i;
						isolate.kill();
						startNewIsolate();
					}))
				)
			]
		);
	}
}

BlurryContainer noMagicSquares(int size) =>
	BlurryContainer(
		size: const Size.fromHeight(64),
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
	);

Container loadingMatrix(double size) =>
	Container(
		alignment: Alignment.topCenter,
		child: BlurryContainer(
			size: Size.square(size),
			child: Shimmer.fromColors(
				period: const Duration(milliseconds: 1000),
				baseColor: Colors.black.withOpacity(0.4),
				highlightColor: Colors.black.withOpacity(0.6),
				child: Container(
					alignment: Alignment.topCenter,
					child: AspectRatio(
						aspectRatio: 1,
						child: Container(
							color: Colors.black,
						)
					)
				)
			)
		)
	);

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
  final Size size;
  final EdgeInsetsGeometry padding;
  final Color bgColor;

  final BorderRadius borderRadius;

  const BlurryContainer({
    Key? key,
    this.child,
    this.blur = 5,
    required this.size,
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
          height: size.height,
          width: size.width,
          padding: padding,
          color: bgColor,
          child: child,
        ),
      ),
    );
}

class MatrixView<T> extends StatelessWidget {
	final Matrix<T> matrix;
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
					children: matrix.map((row) =>
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