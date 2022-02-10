import 'dart:io';
import 'dart:typed_data';

import 'browser.dart' as browser;

Future<Uint8List> getPlatformPixels({
  String? path,
  List<int>? bytes,
  bool removeTempFile = true,
}) async {
  if (path != null) {
    final file = File(path);

    final Uint8List pixels = await file.readAsBytes();
    if (removeTempFile) {
      await file.delete();
    }
    return pixels;
  }
  return browser.getPlatformPixels(bytes: bytes!);
}
