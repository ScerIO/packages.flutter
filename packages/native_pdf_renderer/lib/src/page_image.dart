import 'dart:async';
import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'page.dart';

class PDFPageImage {
  PDFPageImage._({
    @required this.id,
    @required this.pageNumber,
    @required this.width,
    @required this.height,
    @required this.bytes,
    @required this.format,
  });

  static const MethodChannel _channel = MethodChannel('io.scer.pdf.renderer');

  /// Page unique id. Needed for rendering and closing page.
  /// Generated when opening page.
  final String id;

  /// Page number. The first page is 1.
  final int pageNumber;

  /// Width of the rendered area in pixels.
  final int width;

  /// Height of the rendered area in pixels.
  final int height;

  /// Image bytes
  final Uint8List bytes;

  /// Target compression format
  final PDFPageFormat format;

  static Future<PDFPageImage> render({
    @required String pageId,
    @required int width,
    @required int height,
    @required PDFPageFormat format,
    @required String backgroundColor,
  }) async {
    if (format == PDFPageFormat.WEBP && Platform.isIOS) {
      throw Exception(
          'PDF Renderer on IOS platform does not support WEBP format');
    }

    final obj = await _channel.invokeMethod('render', {
      'pageId': pageId,
      'width': width,
      'height': height,
      'format': format.value,
      'backgroundColor': backgroundColor,
    });

    if (!(obj is Map<dynamic, dynamic>)) return null;

    final retWidth = obj['width'] as int, retHeight = obj['height'] as int;
    final pixels = obj['data'] as Uint8List;

    return PDFPageImage._(
      id: pageId,
      pageNumber: obj['pageNumber'] as int,
      width: retWidth,
      height: retHeight,
      bytes: pixels,
      format: format,
    );
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
