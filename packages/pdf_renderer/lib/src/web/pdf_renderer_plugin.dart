import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:pdf_renderer/src/interfaces/platform.dart';
import 'platform.dart';

class NativePdfRendererPlugin extends PdfRendererWeb {
  static void registerWith(Registrar registrar) {
    PdfRenderPlatform.instance = PdfRendererWeb();
  }
}
