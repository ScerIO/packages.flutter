part of 'page.dart';

/// Object containing a rendered image of [PdfPage]
abstract class PdfPageTexture {
  const PdfPageTexture({
    required this.id,
    required this.pageId,
    required this.pageNumber,
  });

  /// Page unique id. Needed for rendering and closing page.
  /// Generated when render page.
  final int id;

  final String? pageId;

  /// Page number. The first page is 1.
  final int pageNumber;

  /// Width of the rendered area in pixels.
  int? get textureWidth;

  /// Height of the rendered area in pixels.
  int? get textureHeight;

  bool get hasUpdatedTexture;

  /// Release the object.
  Future<void> dispose();

  /// Update texture's sub-rectangle
  /// ([destinationX],[destinationY],[width],[height]) with
  /// the sub-rectangle ([sourceX],[sourceY],[width],[height]) of the PDF page
  ///  scaled to [fullWidth] x [fullHeight] size.
  /// The method can also resize the texture if you
  /// specify [textureWidth] and [textureHeight].
  /// Returns true if succeeded.
  Future<bool> updateRect({
    required String documentId,
    int destinationX = 0,
    int destinationY = 0,
    int? width,
    int? height,
    int sourceX = 0,
    int sourceY = 0,
    int? textureWidth,
    int? textureHeight,
    double? fullWidth,
    double? fullHeight,
    String? backgroundColor,
    bool allowAntiAliasing = true,
  });

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  @override
  String toString() => '$runtimeType{'
      'id: $id, '
      'page: $pageNumber,  '
      'textureWidth: $textureWidth, '
      'textureHeight: $textureHeight}';
}
