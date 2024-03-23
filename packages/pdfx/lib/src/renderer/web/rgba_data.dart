import 'dart:js_interop';

import 'package:pdfx/src/renderer/rgba_data.dart';

extension type JSRgbaData._(JSObject _) implements JSObject {
  external factory JSRgbaData({
    int id,
    int width,
    int height,
    JSUint8Array data,
  });

  external int get id;

  external int get width;

  external int get height;

  external JSUint8Array get data;

  RgbaData get toDart => RgbaData(
        id,
        width,
        height,
        data.toDart,
      );
}

extension RgbaDataExt on RgbaData {
  JSRgbaData get toJS => JSRgbaData(
        id: id,
        width: width,
        height: height,
        data: data.toJS,
      );
}
