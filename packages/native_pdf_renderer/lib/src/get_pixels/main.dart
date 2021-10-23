import 'dart:typed_data';

import 'stub.dart'
    if (dart.library.io) 'io.dart'
    if (dart.library.js) 'browser.dart'
    if (dart.library.html) 'browser.dart';

Future<Uint8List> getPixels({
  String? path,
  List<int>? bytes,
  bool removeTempFile = true,
}) =>
    getPlatformPixels(
      path: path,
      bytes: bytes,
      removeTempFile: removeTempFile,
    );
