import 'dart:async';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import './document.dart';
import './page_image.dart';

class PDFPageFormat {
  static const JPEG = 0;
  static const PNG = 1;
  static const WEBP = 2;
}

class PDFPage {
  static const MethodChannel _channel =
      const MethodChannel('io.scer.pdf.renderer');
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

  PDFPage({this.document, this.id, this.pageNumber, this.width, this.height});

  /// Render a full image of specified PDF file.
  ///
  /// [width], [height] specify resolution to render in pixels.
  Future<PDFPageImage> render({
    @required int width,
    @required int height,
    @required int format,
    @required String backgroundColor,
  }) =>
      PDFPageImage.render(
        pageId: id,
        width: width,
        height: height,
        format: format,
        backgroundColor: backgroundColor,
      );

  /// Before open another page it is necessary to close the previous.
  ///
  /// The android platform does not allow parallel rendering.
  Future<void> close() {
    return _channel.invokeMethod('close.page', id);
  }

  @override
  bool operator ==(dynamic other) =>
      other is PDFPage &&
      other.document.hashCode == document.hashCode &&
      other.pageNumber == pageNumber;

  @override
  int get hashCode => document.hashCode ^ pageNumber;

  @override
  String toString() =>
      '$runtimeType{document: $document, page: $pageNumber,  width: $width, height: $height}';
}
