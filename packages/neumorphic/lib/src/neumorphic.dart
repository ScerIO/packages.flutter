/// Based on the code by Ivan Cherepanov
/// https://medium.com/flutter-community/neumorphic-designs-in-flutter-eab9a4de2059
import 'package:flutter/material.dart';
import 'package:neumorphic/src/helpers.dart';

enum NeumorphicStatus {
  concave,
  convex,
}

class Neumorphic extends StatelessWidget {
  Neumorphic({
    this.child,
    this.bevel = 10.0,
    this.status = NeumorphicStatus.convex,
    this.color,
    NeumorphicDecoration decoration,
    this.alignment,
    this.width,
    this.height,
    BoxConstraints constraints,
    this.margin,
    this.padding,
    this.transform,
    Key key,
  })  : blurOffset = Offset(bevel / 5, bevel / 5),
        decoration = decoration ?? NeumorphicDecoration(color: color),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        super(key: key);

  final Widget child;

  /// Elevation relative to parent. Main constituent of Neumorphism
  final double bevel;
  final Offset blurOffset;
  final NeumorphicStatus status;
  final Color color;

  /// The decoration to paint behind the [child].
  ///
  /// A shorthand for specifying just a solid color is available in the
  /// constructor: set the `color` argument instead of the `decoration`
  /// argument.
  final NeumorphicDecoration decoration;

  final AlignmentGeometry alignment;
  final double width;
  final double height;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry margin;
  final EdgeInsets padding;
  final Matrix4 transform;

  @override
  Widget build(BuildContext context) {
    final color = decoration?.color ?? Theme.of(context).backgroundColor;
    final isConcave = status == NeumorphicStatus.concave;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      alignment: alignment,
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      padding: padding,
      transform: transform,
      decoration: BoxDecoration(
        borderRadius: decoration.borderRadius,
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
        shape: decoration.shape,
        border: decoration.border,
      ),
      child: child,
    );
  }
}

class NeumorphicDecoration {
  const NeumorphicDecoration({
    this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.shape = BoxShape.rectangle,
    this.border,
  });

  final Color color;
  final BorderRadiusGeometry borderRadius;
  final BoxShape shape;
  final BoxBorder border;
}
