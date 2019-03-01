import 'dart:ui' show Color;

class HslColor extends Color {
  static int getColorFromHsl(double h, double s, double l, double opacity) {
    List<double> rgb = [0, 0, 0];

    double hue = h / 360 % 1;
    double saturation = s / 100;
    double luminance = l / 100;

    if (hue < 1 / 6) {
      rgb[0] = 1;
      rgb[1] = hue * 6;
    } else if (hue < 2 / 6) {
      rgb[0] = 2 - hue * 6;
      rgb[1] = 1;
    } else if (hue < 3 / 6) {
      rgb[1] = 1;
      rgb[2] = hue * 6 - 2;
    } else if (hue < 4 / 6) {
      rgb[1] = 4 - hue * 6;
      rgb[2] = 1;
    } else if (hue < 5 / 6) {
      rgb[0] = hue * 6 - 4;
      rgb[2] = 1;
    } else {
      rgb[0] = 1;
      rgb[2] = 6 - hue * 6;
    }

    rgb = rgb.map((val) => val + (1 - saturation) * (0.5 - val)).toList();

    if (luminance < 0.5) {
      rgb = rgb.map((val) => luminance * 2 * val).toList();
    } else {
      rgb = rgb.map((val) => luminance * 2 * (1 - val) + 2 * val - 1).toList();
    }

    final resultRgb = rgb.map((val) => (val * 255).round()).toList();

    return ((((opacity * 0xff ~/ 1) & 0xff) << 24) |
            ((resultRgb[0] & 0xff) << 16) |
            ((resultRgb[1] & 0xff) << 8) |
            ((resultRgb[2] & 0xff) << 0)) &
        0xFFFFFFFF;
  }

  /// An immutable 32 bit color value in ARGB format.
  HslColor(double h, double s, double l, {double opacity = 1})
      : super(getColorFromHsl(h, s, l, opacity));
}
