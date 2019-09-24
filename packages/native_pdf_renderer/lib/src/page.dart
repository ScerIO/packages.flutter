import 'dart:async';
import 'package:extension/enum.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'document.dart';
import 'page_image.dart';

class PDFPageFormat extends Enum<int> {
  const PDFPageFormat(int val) : super(val);

  static const PDFPageFormat JPEG = PDFPageFormat(0);
  static const PDFPageFormat PNG = PDFPageFormat(1);

  /// ***Attention!*** Works only on android
  static const PDFPageFormat WEBP = PDFPageFormat(2);
}

class PDFCropDef {
  const PDFCropDef({
    @required this.x,
    @required this.y,
    @required this.width,
    @required this.height,
  });

  final int x, y;
  final int width, height;
}

class PDFPage {
  const PDFPage({
    @required this.document,
    @required this.id,
    @required this.pageNumber,
    @required this.width,
    @required this.height,
  });

  static const MethodChannel _channel = MethodChannel('io.scer.pdf.renderer');
  final PDFDocument document;

  /// Page unique id. Needed for rendering and closing page.
  /// Generated when opening page.
  final String id;

  /// Page number in document.
  /// Starts from 1.
  final int pageNumber;

  /// Page source width in pixels
  final int width;

  /// Page source height in pixels
  final int height;

  /// Render a full image of specified PDF file.
  ///
  /// [width], [height] specify resolution to render in pixels.
  /// As default PNG uses transparent background. For change it you can set
  /// [backgroundColor] property like a hex string ('#000000')
  Future<PDFPageImage> render({
    @required int width,
    @required int height,
    PDFPageFormat format = PDFPageFormat.PNG,
    String backgroundColor,
    PDFCropDef crop,
  }) =>
      PDFPageImage.render(
        pageId: id,
        width: width,
        height: height,
        format: format,
        backgroundColor: backgroundColor,
        crop: crop,
      );

  /// Before open another page it is necessary to close the previous.
  ///
  /// The android platform does not allow parallel rendering.
  Future<void> close() => _channel.invokeMethod('close.page', id);

  @override
  bool operator ==(dynamic other) =>
      other is PDFPage &&
      other.document.hashCode == document.hashCode &&
      other.pageNumber == pageNumber;

  @override
  int get hashCode => document.hashCode ^ pageNumber;

  @override
  String toString() => '$runtimeType{'
      'document: $document, '
      'page: $pageNumber,  '
      'width: $width, '
      'height: $height}';
}
