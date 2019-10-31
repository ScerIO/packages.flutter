import 'dart:async';
import 'dart:io' show File;

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class PDFRenderer {
  static const MethodChannel _channel = MethodChannel('io.scer.pdf_renderer');

  /// Sends the [pdfFile] to the platform which then renders it.
  static Future<List<File>> renderPdf({
    @required String pdfFile,
    bool isAsset = false,
  }) async {
    final Iterable result =
        await _channel.invokeMethod('renderPdf', <String, dynamic>{
      'path': pdfFile,
      'isAsset': isAsset,
    });

    return result.map((path) => File(path)).toList();
  }
}
