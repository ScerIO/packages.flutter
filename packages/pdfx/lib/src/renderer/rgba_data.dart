import 'dart:typed_data';

import 'package:meta/meta.dart';

@immutable
class RgbaData {
  const RgbaData(this.id, this.width, this.height, this.data);

  factory RgbaData.alloc({
    required int id,
    required int width,
    required int height,
  }) =>
      RgbaData(
        id,
        width,
        height,
        Uint8List(width * 4 * height),
      );

  final int id;
  final int width;
  final int height;
  final Uint8List data;

  int get stride => width * 4;
  int getOffset(int x, int y) => (x + y * width) * 4;

  @override
  String toString() => 'RgbaData(id=$id, $width x $height)';
}
