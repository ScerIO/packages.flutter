import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/renderer/io/pigeon.dart',
  objcHeaderOut: './ios/Classes/messages.h',
  objcSourceOut: './ios/Classes/messages.m',
  javaOut: './android/src/main/java/dev/flutter/pigeon/Pigeon.java',
  javaOptions: JavaOptions(
    package: 'dev.flutter.pigeon',
  ),
))
class OpenDataMessage {
  Uint8List? data;
  String? password;
}

class OpenPathMessage {
  String? path;
  String? password;
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
  bool? autoCloseAndroid;
}

class GetPageReply {
  String? id;
  double? width;
  double? height;
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
  bool? forPrint;
}

class RenderPageReply {
  int? width;
  int? height;
  String? path;
  Uint8List? data;
}

class RegisterTextureReply {
  int? id;
}

class UpdateTextureMessage {
  // For android
  String? documentId;
  int? pageNumber;
  // For ios & macos
  String? pageId;
  int? textureId;
  int? width;
  int? height;
  String? backgroundColor;
  int? sourceX;
  int? sourceY;
  int? destinationX;
  int? destinationY;
  double? fullWidth;
  double? fullHeight;
  int? textureWidth;
  int? textureHeight;
  bool? allowAntiAliasing;
}

class ResizeTextureMessage {
  int? textureId;
  int? width;
  int? height;
}

class UnregisterTextureMessage {
  int? id;
}

/// Rebuild: `flutter pub run pigeon --input pigeons/message.dart`
/// After build edit ios/Classes/pigeon/messages.m
/// replace `#import <Flutter/Flutter.h>` to
/// ````
// #if TARGET_OS_IOS
// #import <Flutter/Flutter.h>
// #else
// #import <FlutterMacOS/FlutterMacOS.h>
// #endif
/// ````
///
@HostApi()
abstract class PdfxApi {
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

  RegisterTextureReply registerTexture();
  @async
  void updateTexture(UpdateTextureMessage message);
  @async
  void resizeTexture(ResizeTextureMessage message);
  void unregisterTexture(UnregisterTextureMessage message);
}
