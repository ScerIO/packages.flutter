import 'dart:io';
import 'dart:typed_data';

import 'browser.dart' as browser;

Future<Uint8List> getPlatformPixels({String? path, List<int>? bytes}) async {
  if (path != null) {
    final file = File(path);

    final Uint8List pixels = await file.readAsBytes();
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      await file.delete();
    }
    return pixels;
  }
  return browser.getPlatformPixels(bytes: bytes!);
}
