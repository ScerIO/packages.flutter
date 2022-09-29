import 'dart:async';
import 'dart:typed_data' show Uint8List;
import 'dart:ui';

import 'package:meta/meta.dart';

import 'document.dart';

part 'page_image.dart';
part 'page_texture.dart';

/// Image compression format
enum PdfPageImageFormat {
  jpeg(0),
  png(1),
  // /// ***Attention!*** Works only on android
  // static const PdfPageImageFormat webp = PdfPageImageFormat(2);
  webp(2);

  const PdfPageImageFormat(this.value);
  final int value;
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
    required this.autoCloseAndroid,
  });

  final PdfDocument document;

  /// Page unique id. Needed for rendering and closing page.
  /// Generated when opening page.
  final String? id;

  /// Page number in document.
  /// Starts from 1.
  final int pageNumber;

  /// Page source width in pixels
  final double width;

  /// Page source height in pixels
  final double height;

  final bool autoCloseAndroid;

  /// Is the page closed
  bool isClosed = false;

  /// Render a full image of specified PDF file.
  ///
  /// [width], [height] specify resolution to render in pixels.
  /// As default PNG uses transparent background. For change it you can set
  /// [backgroundColor] property like a hex string ('#FFFFFF')
  /// [format] - image type, all types can be seen here [PdfPageImageFormat]
  /// [cropRect] - render only the necessary part of the image
  /// [quality] - hint to the JPEG and WebP compression algorithms (0-100)
  /// [forPrint] - hint to the rendering quality (Android only)
  Future<PdfPageImage?> render({
    required double width,
    required double height,
    PdfPageImageFormat format = PdfPageImageFormat.jpeg,
    String? backgroundColor,
    Rect? cropRect,
    int quality = 100,
    bool forPrint = false,
    @visibleForTesting bool removeTempFile = true,
  });

  /// Create a new Flutter `Texture`. The object should be released by
  /// calling `dispose` method after use it.
  Future<PdfPageTexture> createTexture();

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
