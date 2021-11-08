import 'dart:async';
import 'dart:typed_data';

import 'package:pdf_renderer/src/interfaces/document.dart';
import 'package:pdf_renderer/src/io/platform_method_channel.dart';
import 'package:pdf_renderer/src/io/platform_pigeon.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:universal_platform/universal_platform.dart';

final _usePigeon = UniversalPlatform.isIOS ||
    UniversalPlatform.isMacOS ||
    UniversalPlatform.isAndroid;

/// Abstraction layer to isolate [PdfDocument] implementation
/// from the public interface.
abstract class PdfRenderPlatform extends PlatformInterface {
  /// Constructs a PdfRenderPlatform.
  PdfRenderPlatform() : super(token: _token);

  static final Object _token = Object();

  static PdfRenderPlatform _instance =
      _usePigeon ? PdfRenderPlatformPigeon() : PdfRenderPlatformMethodChannel();

  /// The default instance of [PdfRenderPlatform] to use.
  ///
  /// Defaults to [PdfRenderPlatformMethodChannel].
  static PdfRenderPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [PdfRenderPlatform] when they register themselves.
  static set instance(PdfRenderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<PdfDocument> openFile(String filePath);

  Future<PdfDocument> openAsset(String name);

  Future<PdfDocument> openData(FutureOr<Uint8List> data);
}

class PdfNotSupportException implements Exception {
  PdfNotSupportException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}
