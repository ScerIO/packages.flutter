import 'dart:math' show pow;
import 'dart:ui' show Color;

class XyzColor extends Color {
  /// An immutable 32 bit color value in ARGB format.
  XyzColor(this.x, this.y, this.z, {double opacity = 1})
      : super(getColorFromXyz(x, y, z, opacity));

  final double x, y, z;

  static int getColorFromXyz(double x, double y, double z, double opacity) {
    final double xp = x / 100;
    final double yp = y / 100;
    final double zp = z / 100;

    final Map<String, double> rgb = {
      'r': xp * 3.2406 + yp * -1.5372 + zp * -0.4986,
      'g': xp * -0.9689 + yp * 1.8758 + zp * 0.0415,
      'b': xp * 0.0557 + yp * -0.2040 + zp * 1.0570
    };

    final Map<String, int> resultRgb = {};

    rgb.forEach((key, value) {
      if (value > 0.0031308) {
        rgb[key] = 1.055 * pow(value, 1 / 2.4) - 0.055;
      } else {
        rgb[key] = value * 12.92;
      }
      resultRgb[key] = (rgb[key] * 255).toInt();
    });

    return ((((opacity * 0xff ~/ 1) & 0xff) << 24) |
            ((resultRgb['r'] & 0xff) << 16) |
            ((resultRgb['g'] & 0xff) << 8) |
            ((resultRgb['b'] & 0xff) << 0)) &
        0xFFFFFFFF;
  }

  Map<String, num> toMap() => {'x': x, 'y': y, 'z': z};

  double operator [](String key) => toMap()[key];
}
