/// Based on the code by Ivan Cherepanov
/// https://medium.com/flutter-community/neumorphic-designs-in-flutter-eab9a4de2059
import 'package:flutter/material.dart';
import 'package:neumorphic/src/helpers.dart';

enum NeumorphicShape {
  concave,
  convex,
}

class Neumorphic extends StatelessWidget {
  Neumorphic({
    this.child,
    this.bevel = 10.0,
    this.color,
    this.padding = const EdgeInsets.all(24.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.neumorphicShape = NeumorphicShape.convex,
    Key key,
  })  : blurOffset = Offset(bevel / 5, bevel / 5),
        super(key: key);

  final Widget child;
  final double bevel;
  final Offset blurOffset;
  final Color color;
  final EdgeInsets padding;
  final BorderRadiusGeometry borderRadius;
  final NeumorphicShape neumorphicShape;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Theme.of(context).backgroundColor;
    final isConcave = neumorphicShape == NeumorphicShape.concave;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isConcave ? color.mix(Colors.black, .05) : color,
            isConcave ? color : color.mix(Colors.black, .01),
            isConcave ? color : color.mix(Colors.black, .01),
            isConcave ? color.mix(Colors.white, .2) : color,
          ],
          stops: [
            0.0,
            .3,
            .6,
            1.0,
          ],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: bevel,
            offset: -blurOffset,
            color: color.mix(Colors.white, .6).withOpacity(0.85),
          ),
          BoxShadow(
            blurRadius: bevel,
            offset: blurOffset,
            color: color.mix(Colors.black, .3).withOpacity(0.85),
          )
        ],
      ),
      child: child,
    );
  }
}
