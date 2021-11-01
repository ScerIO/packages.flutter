import 'dart:async';
import 'dart:typed_data' show Uint8List;
import 'dart:ui';

import 'package:extension/enum.dart';
import 'package:meta/meta.dart';
import 'document.dart';

part 'page_image.dart';

/// Image compression format
class PdfPageFormat extends Enum<int> {
  const PdfPageFormat(int val) : super(val);

  static const PdfPageFormat JPEG = PdfPageFormat(0);
  static const PdfPageFormat PNG = PdfPageFormat(1);

  /// ***Attention!*** Works only on android
  static const PdfPageFormat WEBP = PdfPageFormat(2);
}

/// An integral part of a document is its page,
/// which contains a method [render] for rendering into an image
abstract class PdfPage {
  PdfPage({
    required this.document,
    required this.id,
    required this.pageNumber,
    required this.width,
    required this.height,
  });

  final PdfDocument document;

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
  /// [backgroundColor] property like a hex string ('#FFFFFF')
  /// [format] - image type, all types can be seen here [PdfPageFormat]
  /// [cropRect] - render only the necessary part of the image
  /// [quality] - hint to the JPEG and WebP compression algorithms (0-100)
  Future<PdfPageImage?> render({
    required int width,
    required int height,
    PdfPageFormat format = PdfPageFormat.PNG,
    String? backgroundColor,
    Rect? cropRect,
    int quality = 100,
    @visibleForTesting bool removeTempFile = true,
  });

  // Future<bool> updateTexture({
  //   int destX = 0,
  //   int destY = 0,
  //   int? width,
  //   int? height,
  //   int srcX = 0,
  //   int srcY = 0,
  //   int? texWidth,
  //   int? texHeight,
  //   double? fullWidth,
  //   double? fullHeight,
  //   bool backgroundFill = true,
  //   bool allowAntialiasingIOS = true,
  // }) async {
  //   final result = (await _channel.invokeMethod<int>('update.texture', {
  //     'docId': pdfDocument.id,
  //     'pageNumber': pageNumber,
  //     'texId': texId,
  //     'destX': destX,
  //     'destY': destY,
  //     'width': width,
  //     'height': height,
  //     'srcX': srcX,
  //     'srcY': srcY,
  //     'texWidth': texWidth,
  //     'texHeight': texHeight,
  //     'fullWidth': fullWidth,
  //     'fullHeight': fullHeight,
  //     'backgroundFill': backgroundFill,
  //     'allowAntialiasingIOS': allowAntialiasingIOS,
  //   }))!;
  //   if (result >= 0) {
  //     _texWidth = texWidth ?? _texWidth;
  //     _texHeight = texHeight ?? _texHeight;
  //   }
  //   return result >= 0;
  // }

  /// Before open another page it is necessary to close the previous.
  ///
  /// The android platform does not allow parallel rendering.
  Future<void> close();

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

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
