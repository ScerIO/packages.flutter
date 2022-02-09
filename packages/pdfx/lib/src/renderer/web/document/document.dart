import 'package:js/js_util.dart';
import 'package:pdfx/src/renderer/web/pdfjs.dart';

class Document {
  Document({
    required this.id,
    required this.document,
  });

  final String id;
  final PdfjsDocument document;

  int get pagesCount => document.numPages;

  Map<String, dynamic> get infoMap => {
        'id': id,
        'pagesCount': pagesCount,
      };

  void close() {}

  Future<PdfjsPage> openPage(int? pageNumber) =>
      promiseToFuture<PdfjsPage>(document.getPage(pageNumber!));
}
