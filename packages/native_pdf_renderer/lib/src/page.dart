import 'dart:async';
import 'package:extension/enum.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'document.dart';
import 'page_image.dart';

/// Image compression format
class PDFPageFormat extends Enum<int> {
  const PDFPageFormat(int val) : super(val);

  static const PDFPageFormat JPEG = PDFPageFormat(0);
  static const PDFPageFormat PNG = PDFPageFormat(1);

  /// ***Attention!*** Works only on android
  static const PDFPageFormat WEBP = PDFPageFormat(2);
}

/// Render options for a specific part of the page
@Deprecated('Usage [cropRect] property instead prop')
class PDFCropDef {
  PDFCropDef({
    @required this.x,
    @required this.y,
    @required this.width,
    @required this.height,
  });

  /// Indent left to render part of the page
  final int x;

  /// Indent top to render part of the page
  final int y;

  /// Width required for image rendering
  final int width;

  /// Height required for image rendering
  final int height;

  /// Is the page closed
  bool isClosed = false;

  /// Fallback for generating rect
  Rect get rect => Rect.fromLTWH(
        x.toDouble(),
        y.toDouble(),
        width.toDouble(),
        height.toDouble(),
      );
}

/// An integral part of a document is its page,
/// which contains a method [render] for rendering into an image
class PDFPage {
  PDFPage({
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

  /// Is the page closed
  bool isClosed = false;

  /// Render a full image of specified PDF file.
  ///
  /// [width], [height] specify resolution to render in pixels.
  /// As default PNG uses transparent background. For change it you can set
  /// [backgroundColor] property like a hex string ('#000000')
  /// [format] - image type, all types can be seen here [PDFPageFormat]
  /// [cropRect] - render only the necessary part of the image
  Future<PDFPageImage> render({
    @required int width,
    @required int height,
    PDFPageFormat format = PDFPageFormat.PNG,
    String backgroundColor,
    // ignore: deprecated_member_use_from_same_package
    @Deprecated('Use cropRect instead') PDFCropDef crop,
    Rect cropRect,
  }) {
    if (document.isClosed) {
      throw PdfDocumentAlreadyClosedException();
    } else if (isClosed) {
      throw PdfPageAlreadyClosedException();
    }

    final rect = cropRect ?? crop?.rect;

    return PDFPageImage.render(
      pageId: id,
      pageNumber: pageNumber,
      width: width,
      height: height,
      format: format,
      backgroundColor: backgroundColor,
      crop: rect,
    );
  }

  /// Before open another page it is necessary to close the previous.
  ///
  /// The android platform does not allow parallel rendering.
  Future<void> close() {
    if (isClosed) {
      throw PdfPageAlreadyClosedException();
    } else {
      isClosed = true;
    }
    return _channel.invokeMethod('close.page', id);
  }

  @override
  bool operator ==(Object other) =>
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

class PdfPageAlreadyClosedException implements Exception {
  @override
  String toString() => '$runtimeType: Page already closed';
}
