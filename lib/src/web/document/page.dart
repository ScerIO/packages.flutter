import 'dart:async';
import 'dart:html' as html;
import 'dart:io';
import 'dart:js' as js;
import 'dart:js_util';
import 'dart:typed_data';

import 'package:native_pdf_renderer/src/web/pdfjs.dart';

class Page {
  Page({
    required this.id,
    required this.documentId,
    required this.page,
  }) : _viewport = page.getViewport(Settings()..scale = 1.0);

  final String? id, documentId;
  final PdfJsPage page;
  final PdfJsViewport _viewport;

  int get number => page.pageNumber;

  int get width => _viewport.width.toInt();
  int get height => _viewport.height.toInt();

  Map<String, dynamic> get infoMap => {
        'documentId': documentId,
        'id': id,
        'pageNumber': number,
        'width': width,
        'height': height,
      };

  void close() {}

  Future<Data> render({
    required int width,
    required int height,
  }) async {
    final html.CanvasElement canvas =
        js.context['document'].createElement('canvas');
    final html.CanvasRenderingContext2D? context =
        canvas.getContext('2d') as html.CanvasRenderingContext2D?;

    final viewport =
        page.getViewport(Settings()..scale = width / _viewport.width);

    canvas
      ..height = viewport.height.toInt()
      ..width = viewport.width.toInt();

    final renderContext = Settings()
      ..canvasContext = context
      ..viewport = viewport;

    await promiseToFuture<void>(page.render(renderContext).promise);

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

    return Data(
      width: width,
      height: height,
      data: data.toBytes(),
    );
  }
}

class Data {
  const Data({
    required this.width,
    required this.height,
    required this.data,
  });

  final int? width, height;
  final Uint8List data;

  Map<String, dynamic> get toMap => {
        'width': width,
        'height': height,
        'data': data,
      };
}
