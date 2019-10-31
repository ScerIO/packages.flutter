import 'dart:async';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/services.dart';
import './page.dart';

class PDFDocument {
  static const MethodChannel _channel =
      const MethodChannel('io.scer.pdf.renderer');

  /// Neded for toString method
  /// Сontains a method for opening a document (file, data or asset)
  final String sourceName;

  /// Document unique id.
  /// Generated when opening document.
  final String id;

  /// All pages count in document.
  /// Starts from 1.
  final int pagesCount;

  final List<PDFPage> _pages;

  PDFDocument._({
    this.sourceName,
    this.id,
    this.pagesCount,
  }) : _pages = List<PDFPage>(pagesCount);

  Future<void> close() {
    return _channel.invokeMethod('close.document', id);
  }

  static PDFDocument _open(Map<dynamic, dynamic> obj, String sourceName) =>
      PDFDocument._(
        sourceName: sourceName,
        id: obj['id'] as String,
        pagesCount: obj['pagesCount'] as int,
      );

  static Future<PDFDocument> openFile(String filePath) async => _open(
      await _channel.invokeMethod('open.document.file', filePath),
      'file:$filePath');

  static Future<PDFDocument> openAsset(String name) async => _open(
      await _channel.invokeMethod('open.document.asset', name), 'asset:$name');

  static Future<PDFDocument> openData(Uint8List data) async => _open(
      await _channel.invokeMethod('open.document.data', data), 'memory:$data');

  /// Get page object. The first page is 1.
  Future<PDFPage> getPage(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > pagesCount) return null;
    var page = _pages[pageNumber - 1];
    if (page == null) {
      var obj = await _channel
          .invokeMethod('open.page', {'documentId': id, 'page': pageNumber});
      if (obj is Map<dynamic, dynamic>) {
        page = _pages[pageNumber - 1] = PDFPage(
          document: this,
          id: obj['id'] as String,
          pageNumber: pageNumber,
          width: obj['width'] as int,
          height: obj['height'] as int,
        );
      }
    }
    return page;
  }

  @override
  bool operator ==(dynamic other) => other is PDFDocument && other.id == id;

  @override
  int get hashCode => identityHashCode(id);

  @override
  String toString() =>
      '$runtimeType{document: $sourceName, id: $id, pagesCount: $pagesCount}';
}
