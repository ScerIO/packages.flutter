import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:native_pdf_renderer/document.dart';
import 'package:native_pdf_renderer/page_image.dart';

class PDFPage {
  static const MethodChannel _channel =
      const MethodChannel('io.scer.pdf.renderer');
  final PDFDocument document;

  /// Page unique id. Needed for rendering and closing page.
  /// Generated when opening page.
  final String id;
  final int pageNumber;
  final int width;
  final int height;

  PDFPage({this.document, this.id, this.pageNumber, this.width, this.height});

  /// Render a full image of specified PDF file.
  ///
  /// [width], [height] specify resolution to render in pixels.
  Future<PDFPageImage> render({
    @required int width,
    @required int height,
  }) =>
      PDFPageImage.render(
        pageId: id,
        width: width,
        height: height,
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
