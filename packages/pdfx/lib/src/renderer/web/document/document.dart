import 'dart:js_interop';

import 'package:pdfx/src/renderer/web/pdfjs.dart';

typedef DocumentInfo = ({
  String id,
  int pagesCount,
});

class Document {
  Document({
    required this.id,
    required this.document,
  });

  final String id;
  final PdfjsDocument document;

  int get pagesCount => document.numPages;

  DocumentInfo get info => (
        id: id,
        pagesCount: pagesCount,
      );

  void close() {
    document.destroy();
  }

  Future<PdfjsPage> openPage(int pageNumber) =>
      document.getPage(pageNumber).toDart;
}
