import 'dart:async';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/services.dart';
import 'package:synchronized/synchronized.dart';
import 'page.dart';

/// PDF page image renderer
class PdfDocument {
  PdfDocument._({
    required this.sourceName,
    required this.id,
    required this.pagesCount,
  });

  static const MethodChannel _channel =
      MethodChannel('io.scer.native_pdf_renderer');

  final Lock _lock = Lock();

  /// Needed for toString method
  /// Contains a method for opening a document (file, data or asset)
  final String sourceName;

  /// Document unique id.
  /// Generated when opening document.
  final String id;

  /// All pages count in document.
  /// Starts from 1.
  final int pagesCount;

  /// Is the document closed
  bool isClosed = false;

  /// After you finish working with the document,
  /// you should close it to avoid memory leak.
  Future<void> close() => _lock.synchronized(() async {
        if (isClosed) {
          throw PdfDocumentAlreadyClosedException();
        } else {
          isClosed = true;
        }
        return _channel.invokeMethod('close.document', id);
      });

  static PdfDocument _open(Map<dynamic, dynamic> obj, String sourceName) =>
      PdfDocument._(
        sourceName: sourceName,
        id: obj['id'] as String,
        pagesCount: obj['pagesCount'] as int,
      );

  /// Open PDF document from filesystem path
  static Future<PdfDocument> openFile(String filePath) async => _open(
        (await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'open.document.file',
          filePath,
        ))!,
        'file:$filePath',
      );

  /// Open PDF document from application assets
  static Future<PdfDocument> openAsset(String name) async => _open(
        (await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'open.document.asset',
          name,
        ))!,
        'asset:$name',
      );

  /// Open PDF file from memory (Uint8List)
  static Future<PdfDocument> openData(Uint8List data) async => _open(
        (await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'open.document.data',
          data,
        ))!,
        'memory:binary',
      );

  /// Get page object. The first page is 1.
  Future<PdfPage> getPage(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > pagesCount) {
      throw PdfPageNotFoundException();
    }
    return _lock.synchronized<PdfPage>(() async {
      if (isClosed) {
        throw PdfDocumentAlreadyClosedException();
      }
      final obj = (await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'open.page',
        {
          'documentId': id,
          'page': pageNumber,
        },
      ))!;
      return PdfPage(
        document: this,
        id: obj['id'] as String,
        pageNumber: pageNumber,
        width: obj['width'] as int,
        height: obj['height'] as int,
        lock: _lock,
      );
    });
  }

  @override
  bool operator ==(Object other) => other is PdfDocument && other.id == id;

  @override
  int get hashCode => identityHashCode(id);

  @override
  String toString() =>
      '$runtimeType{document: $sourceName, id: $id, pagesCount: $pagesCount}';
}

class PdfDocumentAlreadyClosedException implements Exception {
  @override
  String toString() => '$runtimeType: Document already closed';
}

class PdfPageNotFoundException implements Exception {
  @override
  String toString() => '$runtimeType: Page is not in the document';
}
