import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/io/pigeon.dart',
  objcHeaderOut: './ios/Classes/messages.h',
  objcSourceOut: './ios/Classes/messages.m',
  javaOut: './android/src/main/java/dev/flutter/pigeon/Pigeon.java',
  javaOptions: JavaOptions(
    package: 'dev.flutter.pigeon',
  ),
))
class OpenDataMessage {
  Uint8List? data;
}

class OpenPathMessage {
  String? path;
}

class OpenReply {
  String? id;
  int? pagesCount;
}

class IdMessage {
  String? id;
}

class GetPageMessage {
  String? documentId;
  int? pageNumber;
}

class GetPageReply {
  String? id;
  int? width;
  int? height;
}

class RenderPageMessage {
  String? pageId;
  int? width;
  int? height;
  int? format;
  String? backgroundColor;
  bool? crop;
  int? cropX;
  int? cropY;
  int? cropHeight;
  int? cropWidth;
  int? quality;
}

class RenderPageReply {
  int? width;
  int? height;
  String? path;
  Uint8List? data;
}

/// Rebuild: `flutter pub run pigeon --input pigeons/message.dart`
@HostApi()
abstract class PdfRendererApi {
  @async
  OpenReply openDocumentData(OpenDataMessage message);
  @async
  OpenReply openDocumentFile(OpenPathMessage message);
  @async
  OpenReply openDocumentAsset(OpenPathMessage message);
  void closeDocument(IdMessage message);

  @async
  GetPageReply getPage(GetPageMessage message);
  @async
  RenderPageReply renderPage(RenderPageMessage message);
  void closePage(IdMessage message);
}
