import 'dart:math' show pow;
import 'dart:ui' show Color;

import './xyz.dart';

class CielabColor extends Color {
  final double l;
  final double a;
  final double b;
  static XyzColor _white = XyzColor(95.047, 100, 108.883);

  static int getColorFromCielab(double l, double a, double b, double opacity) {
    Map<String, num> xyz = {
      'x': a / 500 + (l + 16) / 116,
      'y': (l + 16) / 116,
      'z': (l + 16) / 116 - b / 200
    };

    xyz.forEach((key, value) {
      num cube = pow(value, 3);
      if (cube > 0.008856) {
        xyz[key] = cube;
      } else {
        xyz[key] = (value - 16 / 116) / 7.787;
      }
      xyz[key] *= _white[key];
    });

    return XyzColor.getColorFromXyz(xyz['x'], xyz['y'], xyz['z'], opacity);
  }

  /// An immutable 32 bit color value in ARGB format.
  CielabColor(this.l, this.a, this.b, {double opacity = 1})
      : super(getColorFromCielab(l, a, b, opacity));

  Map<String, num> toMap() => {'l': l, 'a': a, 'b': b};

  operator [](String key) => this.toMap()[key];
}
