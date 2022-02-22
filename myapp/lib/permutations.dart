import 'package:xrange/xrange.dart';
import 'package:rxdart/rxdart.dart';

Stream<Iterable<int>> permutations(int size) =>
	permutations_(integers(1, size + 1));

Stream<Iterable<int>> permutations_(Iterable<int> list) =>
  list.length == 1 ? Stream.value([list.first])
    : list.isEmpty   ? const Stream.empty()
    : Stream.fromIterable(list)
      .flatMap((e) => permutations_([...list]..remove(e))
        .map((permutation) => [e, ...permutation]));