import 'package:collection/collection.dart';
import 'package:list_ext/list_ext.dart';
import 'package:quiver/strings.dart';

enum Align {
	left,
	right,
	center,
}

List<List<T>> makeMatrix<T>(int rows, int cols, T fill) =>
	List<List<T>>.generate(
		rows,
		(i) => List<T>.filled(cols, fill)
	);

String _toString(element) => element.toString();

String matrixToString<T>(List<List<T>> matrix, {
	String elementDelimiter=' ',
	Align? elementAlignment=Align.right,
	String rowDelimiter='\n',
	String rowPrefix='',
	String rowSuffix='',
	String Function(T) elementToString=_toString
}) {
	final stringElements = matrix
		.map((row) => row
		.map((e) => elementToString(e)));
	final maxWidth = stringElements
		.flattened
		.map((s) => s.length)
		.max();

	var alignments = <Align, String Function(String)>{
		Align.right : (s) => s.padLeft(maxWidth),
		Align.left  : (s) => s.padRight(maxWidth),
		Align.center: (s) => center(s, maxWidth, ' ')
	};
	var alignedElement = alignments[elementAlignment] ?? (s) => s;

	String rowToString(Iterable<String> row)
	=>  rowPrefix
		+ row.map(alignedElement)
		     .join(elementDelimiter)
		+ rowSuffix;

	return stringElements
		.map(rowToString)
		.join(rowDelimiter);
}