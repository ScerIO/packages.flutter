import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pdfx/src/renderer/interfaces/page.dart';

class PdfPageImageProvider extends ImageProvider<PdfPageImageProvider> {
  const PdfPageImageProvider(
    this.pdfPageImage,
    this.pageNumber,
    this.documentId, {
    this.scale = 1.0,
  });

  final Future<PdfPageImage> pdfPageImage;
  final int pageNumber;
  final String documentId;

  final double scale;

  @override
  ImageStreamCompleter loadImage(PdfPageImageProvider key, ImageDecoderCallback decode) =>
      MultiFrameImageStreamCompleter(
        codec: _loadAsync(key, decode),
        scale: key.scale,
        informationCollector: () sync* {
          yield ErrorDescription('Page: $pageNumber, DocumentId: $documentId');
        },
      );

  @override
  Future<PdfPageImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<PdfPageImageProvider>(this);

  Future<Codec> _loadAsync(PdfPageImageProvider key, ImageDecoderCallback decode) async {
    assert(key == this);

    final loadedPdfPageImage = await pdfPageImage;
    final Uint8List bytes = loadedPdfPageImage.bytes;

    if (bytes.lengthInBytes == 0) {
      throw StateError('${loadedPdfPageImage.pageNumber} page '
          'cannot be loaded as an image.');
    }

    final ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(bytes);

    return decode(buffer);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    if (other is PdfPageImageProvider &&
        pageNumber == other.pageNumber &&
        documentId == other.documentId &&
        scale == other.scale) {
      return true;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(pageNumber, documentId, scale);
}
