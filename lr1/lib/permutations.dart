import 'package:xrange/xrange.dart';
import 'package:collection/collection.dart';

Iterable<Iterable<int>> permutations(int size) =>
	permutations_(integers(1, size + 1));

Iterable<Iterable<int>> permutations_(Iterable<int> list) =>
	list.length == 1 ? [[list.first]]
	: list.isEmpty   ? Iterable.empty()
	: list
		.map((e) => permutations_([...list]..remove(e))
		.map((permutation) => [e, ...permutation]))
		.flattened;