part of 'page.dart';

/// Object containing a rendered image of [PdfPage]
abstract class PdfPageImage {
  const PdfPageImage({
    required this.id,
    required this.pageNumber,
    required this.width,
    required this.height,
    required this.bytes,
    required this.format,
    required this.quality,
  });

  /// Page unique id. Needed for rendering and closing page.
  /// Generated when render page.
  final String? id;

  /// Page number. The first page is 1.
  final int pageNumber;

  /// Width of the rendered area in pixels.
  final int? width;

  /// Height of the rendered area in pixels.
  final int? height;

  /// Image bytes
  final Uint8List bytes;

  /// Target compression format
  final PdfPageImageFormat format;

  /// Target compression format quality
  final int quality;

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  @override
  String toString() => '$runtimeType{'
      'id: $id, '
      'page: $pageNumber,  '
      'width: $width, '
      'height: $height, '
      'bytesLength: ${bytes.lengthInBytes}}';
}
