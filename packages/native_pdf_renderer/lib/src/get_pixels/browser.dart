import 'dart:typed_data';

Future<Uint8List> getPlatformPixels({
  String? path,
  List<int>? bytes,
  bool removeTempFile = true,
}) =>
    Future.value(Uint8List.fromList(bytes!));
