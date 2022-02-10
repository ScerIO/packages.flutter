export 'implementations/pdf_texture_native.dart'
    if (dart.library.js) 'implementations/pdf_texture_web.dart'
    if (dart.library.html) 'implementations/pdf_texture_web.dart';
