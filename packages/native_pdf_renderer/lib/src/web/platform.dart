import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:js/js_util.dart';
import 'package:meta/meta.dart';

import 'package:native_pdf_renderer/src/interfaces/document.dart';
import 'package:native_pdf_renderer/src/interfaces/page.dart';
import 'package:native_pdf_renderer/src/interfaces/platform.dart';
import 'package:native_pdf_renderer/src/web/pdfjs.dart';
import 'package:native_pdf_renderer/src/web/resources/document_repository.dart';
import 'package:native_pdf_renderer/src/web/resources/page_repository.dart';

final _documents = DocumentRepository();
final _pages = PageRepository();

class PdfRendererWeb extends PdfRenderPlatform {
  PdfDocument _open(Map<dynamic, dynamic> obj, String sourceName) =>
      PdfDocumentWeb._(
        sourceName: sourceName,
        id: obj['id'] as String,
        pagesCount: obj['pagesCount'] as int,
      );

  Future<Map<String, dynamic>> _openDocumentData(ByteBuffer data) async {
    final document = await pdfjsGetDocumentFromData(data);

    return _documents.register(document).infoMap;
  }

  @override
  Future<PdfDocument> openAsset(String name) async {
    final bytes = await rootBundle.load(name);
    final data = bytes.buffer;
    final obj = await _openDocumentData(data);

    return _open(obj, 'asset:$name');
  }

  @override
  Future<PdfDocument> openData(Uint8List data) async {
    final obj = await _openDocumentData(data.buffer);

    return _open(obj, 'memory:binary');
  }

  @override
  Future<PdfDocument> openFile(String filePath) {
    throw PlatformException(
        code: 'Unimplemented',
        details: 'The plugin for web doesn\'t implement '
            'the method \'openFile\'');
  }
}

/// Handles PDF document loaded on memory.
class PdfDocumentWeb extends PdfDocument {
  PdfDocumentWeb._({
    required String sourceName,
    required String id,
    required int pagesCount,
  }) : super(
          sourceName: sourceName,
          id: id,
          pagesCount: pagesCount,
        );

  @override
  Future<void> close() async {
    _documents.close(id);
  }

  /// Get page object. The first page is 1.
  @override
  Future<PdfPage> getPage(int pageNumber) async {
    final jsPage = await _documents.get(id)!.openPage(pageNumber);
    final data = _pages.register(id, jsPage).infoMap;

    final page = PdfPageWeb(
      document: this,
      pageNumber: pageNumber,
      pdfJsPage: jsPage,
      id: data['id'] as String,
      width: data['width'] as int,
      height: data['height'] as int,
    );
    return page;
  }

  @override
  bool operator ==(Object other) => other is PdfDocumentWeb && other.id == id;

  @override
  int get hashCode => identityHashCode(id);
}

class PdfPageWeb extends PdfPage {
  PdfPageWeb({
    required PdfDocument document,
    required String id,
    required int pageNumber,
    required int width,
    required int height,
    required this.pdfJsPage,
  }) : super(
          document: document,
          id: id,
          pageNumber: pageNumber,
          width: width,
          height: height,
        );

  final PdfjsPage pdfJsPage;

  @override
  Future<PdfPageImage?> render({
    required int width,
    required int height,
    PdfPageFormat format = PdfPageFormat.PNG,
    String? backgroundColor,
    Rect? cropRect,
    int quality = 100,
    @visibleForTesting bool removeTempFile = true,
  }) {
    if (document.isClosed) {
      throw PdfDocumentAlreadyClosedException();
    } else if (isClosed) {
      throw PdfPageAlreadyClosedException();
    }

    return PdfPageImageWeb.render(
      pageId: id,
      pageNumber: pageNumber,
      width: width,
      height: height,
      format: format,
      backgroundColor: backgroundColor,
      crop: cropRect,
      quality: quality,
      removeTempFile: removeTempFile,
      pdfJsPage: pdfJsPage,
    );
  }

  @override
  Future<void> close() async {
    _pages.close(id);
  }

  @override
  bool operator ==(Object other) =>
      other is PdfPageWeb &&
      other.document.hashCode == document.hashCode &&
      other.pageNumber == pageNumber;

  @override
  int get hashCode => document.hashCode ^ pageNumber;
}

class PdfPageImageWeb extends PdfPageImage {
  PdfPageImageWeb({
    required String? id,
    required int pageNumber,
    required int? width,
    required int? height,
    required Uint8List bytes,
    required this.pdfJsPage,
    required PdfPageFormat format,
    required int quality,
  }) : super(
          id: id,
          pageNumber: pageNumber,
          width: width,
          height: height,
          bytes: bytes,
          format: format,
          quality: quality,
        );

  final PdfjsPage pdfJsPage;

  /// Render a full image of specified PDF file.
  ///
  /// [width], [height] specify resolution to render in pixels.
  /// As default PNG uses transparent background. For change it you can set
  /// [backgroundColor] property like a hex string ('#000000')
  /// [format] - image type, all types can be seen here [PdfPageFormat]
  /// [crop] - render only the necessary part of the image
  /// [quality] - hint to the JPEG and WebP compression algorithms (0-100)
  static Future<PdfPageImage?> render({
    required String? pageId,
    required int pageNumber,
    required int width,
    required int height,
    required PdfPageFormat format,
    required String? backgroundColor,
    required Rect? crop,
    required int quality,
    required bool removeTempFile,
    required PdfjsPage pdfJsPage,
  }) async {
    final _viewport = pdfJsPage.getViewport(PdfjsViewportParams(scale: 1));
    final html.CanvasElement canvas =
        js.context['document'].createElement('canvas');
    final html.CanvasRenderingContext2D context =
        canvas.getContext('2d') as html.CanvasRenderingContext2D;

    final viewport = pdfJsPage
        .getViewport(PdfjsViewportParams(scale: width / _viewport.width));

    canvas
      ..height = viewport.height.toInt()
      ..width = viewport.width.toInt();

    final renderContext = PdfjsRenderContext(
      canvasContext: context,
      viewport: viewport,
    );

    await promiseToFuture<void>(pdfJsPage.render(renderContext).promise);

    // Convert the image to PNG
    final completer = Completer<void>();
    final blob = await canvas.toBlob();
    final data = BytesBuilder();
    final reader = html.FileReader()..readAsArrayBuffer(blob);
    reader.onLoadEnd.listen(
      (html.ProgressEvent e) {
        data.add(reader.result as List<int>);
        completer.complete();
      },
    );
    await completer.future;

    return PdfPageImageWeb(
      id: pageId,
      pageNumber: pageNumber,
      width: width,
      height: height,
      bytes: data.toBytes(),
      format: format,
      quality: quality,
      pdfJsPage: pdfJsPage,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PdfPageImageWeb &&
      other.bytes.lengthInBytes == bytes.lengthInBytes;

  @override
  int get hashCode => identityHashCode(id) ^ pageNumber;
}
