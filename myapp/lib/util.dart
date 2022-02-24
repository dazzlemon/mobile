import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

ListView listViewWithOutsideSeparators(Iterable<Widget>children, Widget Function(BuildContext, int) separatorBuilder) {
	var items = [Container(), ...children, Container()];
	return 	ListView.separated(
		itemBuilder: (_, i) => items.elementAt(i),
		separatorBuilder: separatorBuilder,
		itemCount: items.length
	);
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

const Color kBaseColor = Color.fromRGBO(0, 0, 0, .4);
const Color kHighlightColor = Color.fromRGBO(0, 0, 0, .6);

Container frostedGlassShimmer(Size size, {
	Duration period = const Duration(milliseconds: 1500),
	Color baseColor = kBaseColor,
	Color highlightColor = kHighlightColor
}) =>
	Container(
		alignment: Alignment.topCenter,
		child: BlurryContainer(
			size: size,
			child: Shimmer.fromColors(
				period: period,
				baseColor: baseColor,
				highlightColor: highlightColor,
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