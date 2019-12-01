import 'dart:async';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'page.dart';

/// PDF page image renderer
class PDFDocument {
  PDFDocument._({
    @required this.sourceName,
    @required this.id,
    @required this.pagesCount,
  });

  static const MethodChannel _channel = MethodChannel('io.scer.pdf.renderer');

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
  Future<void> close() {
    if (isClosed) {
      throw PdfDocumentAlreadyClosedException();
    } else {
      isClosed = true;
    }
    return _channel.invokeMethod('close.document', id);
  }

  static PDFDocument _open(Map<dynamic, dynamic> obj, String sourceName) =>
      PDFDocument._(
        sourceName: sourceName,
        id: obj['id'] as String,
        pagesCount: obj['pagesCount'] as int,
      );

  /// Open PDF document from filesystem path
  static Future<PDFDocument> openFile(String filePath) async => _open(
        await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'open.document.file',
          filePath,
        ),
        'file:$filePath',
      );

  /// Open PDF document from application assets
  static Future<PDFDocument> openAsset(String name) async => _open(
        await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'open.document.asset',
          name,
        ),
        'asset:$name',
      );

  /// Open PDF file from memory (Uint8List)
  static Future<PDFDocument> openData(Uint8List data) async => _open(
        await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'open.document.data',
          data,
        ),
        'memory:$data',
      );

  /// Get page object. The first page is 1.
  Future<PDFPage> getPage(int pageNumber) async {
    if (isClosed) {
      throw PdfDocumentAlreadyClosedException();
    }
    if (pageNumber < 1 || pageNumber > pagesCount) {
      throw PdfPageNotFoundException();
    }
    final obj = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'open.page',
      {
        'documentId': id,
        'page': pageNumber,
      },
    );
    return PDFPage(
      document: this,
      id: obj['id'] as String,
      pageNumber: pageNumber,
      width: obj['width'] as int,
      height: obj['height'] as int,
    );
  }

  @override
  bool operator ==(Object other) => other is PDFDocument && other.id == id;

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
