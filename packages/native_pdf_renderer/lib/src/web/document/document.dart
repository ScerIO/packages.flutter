import 'dart:js_util';

import 'package:native_pdf_renderer/src/web/pdfjs.dart';

class Document {
  Document({
    required this.id,
    required this.document,
  });

  final String id;
  final PdfJsDoc document;

  int get pagesCount => document.numPages;

  Map<String, dynamic> get infoMap => {
        'id': id,
        'pagesCount': pagesCount,
      };

  void close() {}

  Future<PdfJsPage> openPage(int? pageNumber) =>
      promiseToFuture<PdfJsPage>(document.getPage(pageNumber));
}
