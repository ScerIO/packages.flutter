import 'dart:typed_data';

import 'package:native_pdf_renderer/src/interfaces/document.dart';
import 'package:native_pdf_renderer/src/io/platform_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Abstraction layer to isolate [PdfDocument]/[PdfPageImageTexture] implementation from the public interface.
abstract class PdfRenderPlatform extends PlatformInterface {
  /// Constructs a PdfRenderPlatform.
  PdfRenderPlatform() : super(token: _token);

  static final Object _token = Object();

  static PdfRenderPlatform _instance = PdfRenderPlatformMethodChannel();

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

  Future<PdfDocument> openData(Uint8List data);
}
