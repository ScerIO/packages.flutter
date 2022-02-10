import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js_util.dart' as js_util;
import 'package:meta/meta.dart';

import 'package:pdfx/src/renderer/interfaces/document.dart';
import 'package:pdfx/src/renderer/interfaces/page.dart';
import 'package:pdfx/src/renderer/interfaces/platform.dart';
import 'package:pdfx/src/renderer/rgba_data.dart';
import 'package:pdfx/src/renderer/web/pdfjs.dart';
import 'package:pdfx/src/renderer/web/resources/document_repository.dart';
import 'package:pdfx/src/renderer/web/resources/page_repository.dart';

final _documents = DocumentRepository();
final _pages = PageRepository();
final _textures = <int, RgbaData>{};
int _texId = -1;

class PdfxWeb extends PdfxPlatform {
  PdfxWeb() {
    _eventChannel.setController(_eventStreamController);
  }

  static final _eventStreamController = StreamController<int>();
  final _eventChannel =
      const PluginEventChannel('io.scer.pdf_renderer/web_events');

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
  Future<PdfDocument> openData(FutureOr<Uint8List> data) async {
    final obj = await _openDocumentData((await data).buffer);

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
  Future<PdfPage> getPage(
    int pageNumber, {
    bool autoCloseAndroid = false,
  }) async {
    final jsPage = await _documents.get(id)!.openPage(pageNumber);
    final data = _pages.register(id, jsPage).infoMap;

    final page = PdfPageWeb(
      document: this,
      pageNumber: pageNumber,
      pdfJsPage: jsPage,
      id: data['id'] as String,
      width: data['width'] as double,
      height: data['height'] as double,
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
    required double width,
    required double height,
    required this.pdfJsPage,
  }) : super(
          document: document,
          id: id,
          pageNumber: pageNumber,
          width: width,
          height: height,
          autoCloseAndroid: false,
        );

  final PdfjsPage pdfJsPage;

  @override
  Future<PdfPageImage?> render({
    required double width,
    required double height,
    PdfPageImageFormat format = PdfPageImageFormat.png,
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
      width: width.toInt(),
      height: height.toInt(),
      format: format,
      backgroundColor: backgroundColor,
      crop: cropRect,
      quality: quality,
      removeTempFile: removeTempFile,
      pdfJsPage: pdfJsPage,
    );
  }

  @override
  Future<PdfPageTexture> createTexture() async => PdfPageTextureWeb(
        id: ++_texId,
        pageId: id,
        pageNumber: pageNumber,
      );

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
    required PdfPageImageFormat format,
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
  /// [format] - image type, all types can be seen here [PdfPageImageFormat]
  /// [crop] - render only the necessary part of the image
  /// [quality] - hint to the JPEG and WebP compression algorithms (0-100)
  static Future<PdfPageImage?> render({
    required String? pageId,
    required int pageNumber,
    required int width,
    required int height,
    required PdfPageImageFormat format,
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

    await js_util
        .promiseToFuture<void>(pdfJsPage.render(renderContext).promise);

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

class PdfPageTextureWeb extends PdfPageTexture {
  PdfPageTextureWeb({
    required int id,
    required String? pageId,
    required int pageNumber,
  }) : super(
          id: id,
          pageId: pageId,
          pageNumber: pageNumber,
        );

  int? _texWidth;
  int? _texHeight;

  @override
  int? get textureWidth => _texWidth;
  @override
  int? get textureHeight => _texHeight;
  @override
  bool get hasUpdatedTexture => _texWidth != null;

  @override
  Future<void> dispose() async {
    _textures.remove(id);
    js_util.setProperty(html.window, 'pdfx_texture_$id', null);
  }

  @override
  Future<bool> updateRect({
    required String documentId,
    int destinationX = 0,
    int destinationY = 0,
    int? width,
    int? height,
    int sourceX = 0,
    int sourceY = 0,
    int? textureWidth,
    int? textureHeight,
    double? fullWidth,
    double? fullHeight,
    String? backgroundColor,
    bool allowAntiAliasing = true,
  }) async {
    try {
      await _renderRaw(
        documentId: documentId,
        pageNumber: pageNumber,
        pageId: pageId!,
        sourceX: sourceX,
        sourceY: sourceY,
        width: width,
        height: height,
        fullWidth: fullWidth,
        backgroundColor: backgroundColor,
        dontFlip: true,
        handleRawData: (src, width, height) async {
          final destX = destinationX;
          final destY = destinationY;
          final data = _updateTexSize(id, textureWidth!, textureHeight!);
          final destStride = data.stride;
          final bpl = width * 4;
          int dp = data.getOffset(destX, destY);
          int sp = bpl * (height - 1);
          for (int y = 0; y < height; y++) {
            for (int i = 0; i < bpl; i++) {
              data.data[dp + i] = src[sp + i];
            }
            dp += destStride;
            sp -= bpl;
          }
          PdfxWeb._eventStreamController.sink.add(id);

          return true;
        },
      );
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  int get hashCode => identityHashCode(id) ^ pageNumber;

  @override
  bool operator ==(Object other) =>
      other is PdfPageTextureWeb &&
      other.id == id &&
      other.pageId == pageId &&
      other.pageNumber == pageNumber;

  RgbaData _updateTexSize(int id, int width, int height) {
    final oldData = _textures[id];
    if (oldData != null && oldData.width == width && oldData.height == height) {
      return oldData;
    }
    final data = _textures[id] = RgbaData.alloc(
      id: id,
      width: width,
      height: height,
    );
    js_util.setProperty(html.window, 'pdfx_texture_$id', data);
    return data;
  }

  Future<bool> _renderRaw({
    required String documentId,
    required int pageNumber,
    required String pageId,
    required HandleRawData handleRawData,
    required bool dontFlip,
    int sourceX = 0,
    int sourceY = 0,
    int? width,
    int? height,
    double? fullWidth,
    // double? fullHeight,
    String? backgroundColor,
  }) async {
    final docId = documentId;
    final doc = _documents.get(docId);
    if (doc == null) {
      return false;
    }
    if (pageNumber < 1 || pageNumber > doc.pagesCount) {
      return false;
    }
    final page = _pages.get(pageId)!;

    final vp1 = page.renderer.getViewport(PdfjsViewportParams(scale: 1));
    final pw = vp1.width;
    //final ph = vp1.height;
    final _fullWidth = fullWidth ?? pw;
    //final fullHeight = args['fullHeight'] as double? ?? ph;
    final _width = width;
    final _height = height;
    if (_width == null || _height == null || _width <= 0 || _height <= 0) {
      return false;
    }

    final offsetX = -sourceX.toDouble();
    final offsetY = -sourceY.toDouble();

    final vp = page.renderer.getViewport(PdfjsViewportParams(
      scale: _fullWidth / pw,
      offsetX: offsetX,
      offsetY: offsetY,
      dontFlip: dontFlip,
    ));

    final canvas = (html.document.createElement('canvas') as html.CanvasElement)
      ..width = _width
      ..height = _height;

    final html.CanvasRenderingContext2D context =
        canvas.getContext('2d') as html.CanvasRenderingContext2D;

    if (backgroundColor != null) {
      context
        ..fillStyle = backgroundColor
        ..fillRect(0, 0, _width, _height);
    }

    final rendererContext = PdfjsRenderContext(
      canvasContext: context,
      viewport: vp,
    );

    await js_util
        .promiseToFuture<void>(page.renderer.render(rendererContext).promise);

    final data =
        context.getImageData(0, 0, _width, _height).data.buffer.asUint8List();

    // // Convert the image to PNG
    // final completer = Completer<void>();
    // final blob = await canvas.toBlob();
    // final data = BytesBuilder();
    // final reader = html.FileReader()..readAsArrayBuffer(blob);
    // reader.onLoadEnd.listen(
    //   (html.ProgressEvent e) {
    //     data.add(reader.result as List<int>);
    //     completer.complete();
    //   },
    // );
    // await completer.future;

    return handleRawData(data, _width, _height);
  }
}

typedef HandleRawData = FutureOr<bool> Function(
  Uint8List src,
  int width,
  int height,
);
