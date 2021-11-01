import 'package:flutter/services.dart';
import 'package:native_pdf_renderer/src/interfaces/document.dart';

class PdfPageImageTexture {
  PdfPageImageTexture({
    required this.pdfDocument,
    required this.pageNumber,
    required this.texId,
  });

  final PdfDocument pdfDocument;
  final int pageNumber;
  final int texId;

  int? _texWidth;
  int? _texHeight;

  int? get texWidth => _texWidth;
  int? get texHeight => _texHeight;
  bool get hasUpdatedTexture => texWidth != null;

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  static const MethodChannel _channel =
      MethodChannel('io.scer.native_pdf_renderer');

  /// Release the object.
  Future<void> dispose() => _channel.invokeMethod('dispose.texture', texId);

  /// Update texture's sub-rectangle ([destX],[destY],[width],[height])
  /// with the sub-rectangle ([srcX],[srcY],[width],[height]) of the PDF page
  ///  scaled to [fullWidth] x [fullHeight] size.
  /// If [backgroundFill] is true, the sub-rectangle is filled with white before
  ///  rendering the page content.
  /// The method can also resize the texture if
  /// you specify [texWidth] and [texHeight].
  /// Returns true if succeeded.
  Future<bool> updateTexture({
    int destX = 0,
    int destY = 0,
    int? width,
    int? height,
    int srcX = 0,
    int srcY = 0,
    int? texWidth,
    int? texHeight,
    double? fullWidth,
    double? fullHeight,
    bool backgroundFill = true,
    bool allowAntialiasingIOS = true,
  }) async {
    final result = (await _channel.invokeMethod<int>('update.texture', {
      'docId': pdfDocument.id,
      'pageNumber': pageNumber,
      'texId': texId,
      'destX': destX,
      'destY': destY,
      'width': width,
      'height': height,
      'srcX': srcX,
      'srcY': srcY,
      'texWidth': texWidth,
      'texHeight': texHeight,
      'fullWidth': fullWidth,
      'fullHeight': fullHeight,
      'backgroundFill': backgroundFill,
      'allowAntialiasingIOS': allowAntialiasingIOS,
    }))!;
    if (result >= 0) {
      _texWidth = texWidth ?? _texWidth;
      _texHeight = texHeight ?? _texHeight;
    }
    return result >= 0;
  }
}
