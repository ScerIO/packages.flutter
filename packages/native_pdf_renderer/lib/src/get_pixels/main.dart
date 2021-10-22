import 'dart:typed_data';
// ignore: uri_does_not_exist
import 'stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'browser.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'io.dart';

Future<Uint8List> getPixels({String? path, List<int>? bytes}) =>
    getPlatformPixels(
      path: path,
      bytes: bytes,
    );
