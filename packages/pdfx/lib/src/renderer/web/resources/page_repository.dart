import 'package:pdfx/src/renderer/web/document/page.dart';
import 'package:pdfx/src/renderer/web/pdfjs.dart';
import 'package:pdfx/src/renderer/web/resources/repository.dart';

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
