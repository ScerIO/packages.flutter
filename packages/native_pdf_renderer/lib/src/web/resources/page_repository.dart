import 'package:native_pdf_renderer/src/web/document/page.dart';
import 'package:native_pdf_renderer/src/web/pdfjs.dart';
import 'package:native_pdf_renderer/src/web/resources/repository.dart';
import 'package:uuid/uuid.dart';

final Uuid uuid = Uuid();

class PageRepository extends Repository<Page> {
  /// Register document in repository
  Page register(String? documentId, PdfJsPage renderer) {
    final page = Page(
      id: uuid.v1(),
      documentId: documentId,
      page: renderer,
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
