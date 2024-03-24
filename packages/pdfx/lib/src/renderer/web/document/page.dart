import 'package:pdfx/src/renderer/web/pdfjs.dart';

typedef PageInfo = ({
  String id,
  String? documentId,
  int pageNumber,
  double width,
  double height,
});

class Page {
  Page({
    required this.id,
    required this.documentId,
    required this.renderer,
  }) : _viewport = renderer.getViewport(PdfjsViewportParams(scale: 1));

  final String id;
  final String? documentId;
  final PdfjsPage renderer;
  final PdfjsViewport _viewport;

  int get number => renderer.pageNumber;

  double get width => _viewport.width;

  double get height => _viewport.height;

  PageInfo get info => (
        id: id,
        documentId: documentId,
        pageNumber: number,
        width: width,
        height: height,
      );

  void close() {}
}
