import 'dart:typed_data';

import 'stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'browser.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'io.dart';

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
