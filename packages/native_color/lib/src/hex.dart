import 'dart:ui' show Color;

class HexColor extends Color {
  static int getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) hexColor = 'FF' + hexColor;
    return int.parse(hexColor, radix: 16);
  }

  /// An immutable 32 bit color value in ARGB format.
  ///
  /// ```dart
  /// HexColor('000000')    == Color(0xFF000000)
  /// HexColor('FFFFFFFF')  == Color(0xFFFFFFFF)
  /// HexColor('#B1000000') == Color(0xB1000000)
  /// HexColor('#FFFFFF')   == Color(0xFFFFFFFF)
  /// ```
  HexColor(final String hexColor) : super(getColorFromHex(hexColor));
}
