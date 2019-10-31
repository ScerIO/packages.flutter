import 'dart:async';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/services.dart';

class PDFPageImage {
  static const MethodChannel _channel =
      const MethodChannel('io.scer.pdf.renderer');

  /// Page unique id. Needed for rendering and closing page.
  /// Generated when opening page.
  final String id;

  /// Page number. The first page is 1.
  final int pageNumber;

  /// Width of the rendered area in pixels.
  final int width;

  /// Height of the rendered area in pixels.
  final int height;

  /// PNG Bytes
  final Uint8List bytes;

  PDFPageImage._({
    this.id,
    this.pageNumber,
    this.width,
    this.height,
    this.bytes,
  });

  static Future<PDFPageImage> render({
    String pageId,
    int width = 0,
    int height = 0,
  }) async {
    final obj = await _channel.invokeMethod('render', {
      'pageId': pageId,
      'width': width,
      'height': height,
    });

    if (obj is Map<dynamic, dynamic>) {
      final retWidth = obj['width'] as int;
      final retHeight = obj['height'] as int;
      final pixels = obj['data'] as Uint8List;

      return PDFPageImage._(
        id: pageId,
        pageNumber: obj['pageNumber'] as int,
        width: retWidth,
        height: retHeight,
        bytes: pixels,
      );
    }
    return null;
  }

  @override
  bool operator ==(dynamic other) =>
      other is PDFPageImage && other.bytes.lengthInBytes == bytes.lengthInBytes;

  @override
  int get hashCode => identityHashCode(id) ^ pageNumber;

  @override
  String toString() =>
      '$runtimeType{id: $id, page: $pageNumber,  width: $width, height: $height, bytesLength: ${bytes.lengthInBytes}}';
}
