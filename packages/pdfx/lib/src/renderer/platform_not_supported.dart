
import 'dart:async';

import 'dart:typed_data';

import 'package:pdfx/src/renderer/interfaces/document.dart';
import 'package:pdfx/src/renderer/interfaces/platform.dart';

class PdfxPlatformNotSupported extends PdfxPlatform {
  @override
  Future<PdfDocument> openAsset(String name, {String? password}) => throw PlatformNotSupportedException();

  @override
  Future<PdfDocument> openData(FutureOr<Uint8List> data, {String? password}) => throw PlatformNotSupportedException();

  @override
  Future<PdfDocument> openFile(String filePath, {String? password}) => throw PlatformNotSupportedException();
}
