import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:typed_data';

import 'package:js/js_util.dart';
import 'package:pdfx/src/renderer/web/pdfjs.dart';

class Page {
  Page({
    required this.id,
    required this.documentId,
    required this.renderer,
  }) : _viewport = renderer.getViewport(PdfjsViewportParams(scale: 1));

  final String? id, documentId;
  final PdfjsPage renderer;
  final PdfjsViewport _viewport;

  int get number => renderer.pageNumber;

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
    final html.CanvasRenderingContext2D context = canvas
        .getContext('2d', {"alpha": false}) as html.CanvasRenderingContext2D;

    final viewport = renderer
        .getViewport(PdfjsViewportParams(scale: width / _viewport.width));

    canvas
      ..height = viewport.height.toInt()
      ..width = viewport.width.toInt();

    final renderContext = PdfjsRenderContext(
      canvasContext: context,
      viewport: viewport,
    );

    await promiseToFuture<void>(renderer.render(renderContext).promise);

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
