import 'dart:ui' show Color;

extension ColorHelper on Color {
  /// Make color lighter by so many [percents]
  Color lighter(int percents) {
    assert(percents >= 1 && percents <= 100);
    final int rgbPercent = (percents / 100 * 255).round();
    int red = this.red + rgbPercent,
        green = this.green + rgbPercent,
        blue = this.blue + rgbPercent;
    if (red > 255) {
      red = 255;
    }
    if (green > 255) {
      green = 255;
    }
    if (blue > 255) {
      blue = 255;
    }
    return Color.fromARGB(alpha, red, green, blue);
  }

  /// Make color darker by so many [percents]
  Color darker(int percents) {
    assert(percents >= 1 && percents <= 100);
    final int rgbPercent = (percents / 100 * 255).round();
    int red = this.red - rgbPercent,
        green = this.green - rgbPercent,
        blue = this.blue - rgbPercent;
    if (red < 0) {
      red = 0;
    }
    if (green < 0) {
      green = 0;
    }
    if (blue < 0) {
      blue = 0;
    }
    return Color.fromARGB(alpha, red, green, blue);
  }
}
