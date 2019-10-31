# native_pdf_view

Flutter Plugin to render a PDF file. Supports both Android and iOS.

## Getting Started
In your flutter project add the dependency:
```dart
dependencies:
  ...
  native_pdf_view: any
```
For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## Usage example
Import `native_pdf_view.dart`
```dart
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:photo_view/photo_view.dart';

// Load from asset
Widget pdfViewAsset(String path) {
  return NativePDFView(
    pdfFile: 'assets/sample.pdf',
    isAsset: true,
    pageBuilder: (imageFile) => PhotoView(
      imageProvider: FileImage(imageFile),
      initialScale: .40,
      maxScale: 1.75,
      minScale: .40,
      backgroundDecoration: BoxDecoration(
        color: Colors.white,
      ),
    ),
  );
}

// Load from filesystem
Widget pdfViewFS(String path) {
  return NativePDFView(
    pdfFile: 'path/to/pdf/in/file/system/on/you/smartphone',
    isAsset: false,
    pageBuilder: (imageFile) => PhotoView(
      imageProvider: FileImage(imageFile),
      initialScale: .40,
      maxScale: 1.75,
      minScale: .40,
      backgroundDecoration: BoxDecoration(
        color: Colors.white,
      ),
    ),
  );
}
```

## Rendering PDF files on Android devices
Use the provided widget `PdfRenderer` in order to render a PDF file.
This plugin uses the Android native [PdfRenderer](https://developer.android.com/reference/android/graphics/pdf/PdfRenderer) to render
the pages of PDF files and provides a widget called `PdfRenderer` to display the PDF page you like.
