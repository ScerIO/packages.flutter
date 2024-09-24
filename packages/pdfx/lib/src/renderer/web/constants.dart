import 'package:pdfx/src/renderer/web/pdfjs.dart';

class Constants {
  static PdfjsRenderOptions defaultPdfjsRenderOptions = PdfjsRenderOptions.constant(
    cMapUrl: 'https://cdn.jsdelivr.net/npm/pdfjs-dist@4.6.82/cmaps/',
    cMapPacked: true,
  );
}
