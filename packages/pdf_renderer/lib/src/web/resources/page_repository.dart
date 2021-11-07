import 'package:pdf_renderer/src/web/document/page.dart';
import 'package:pdf_renderer/src/web/pdfjs.dart';
import 'package:pdf_renderer/src/web/resources/repository.dart';

class PageRepository<T> extends Repository<Page> {
  /// Register document in repository
  Page register(String? documentId, PdfjsPage renderer) {
    final page = Page(
      id: uuid.v1(),
      documentId: documentId,
      renderer: renderer,
    );
    set(page.id, page);
    return page;
  }

  @override
  void close(String? id) {
    get(id)!.close();
    super.close(id);
  }
}
