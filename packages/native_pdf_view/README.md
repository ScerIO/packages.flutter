# native_pdf_view

*Attention! Doth use this plugin, It is in early development and full of errors.*
Use [native_pdf_renderer](../native_pdf_renderer/README.md) instead

`Flutter` Plugin to render PDF and show a PDF file on both **Android 5.0+** and **iOS 11.0+** devices.
## Getting Started
In your flutter project add the dependency:

[![pub package](https://img.shields.io/pub/v/native_pdf_view.svg)](https://pub.dartlang.org/packages/native_pdf_view)

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
```

## Rendering PDF files on Android devices
This plugin uses the Android native [PdfRenderer](https://developer.android.com/reference/android/graphics/pdf/PdfRenderer) to render
the pages of PDF files and provides a widget called `PdfRenderer` to display the PDF page you like.

## Rendering PDF files on IOS devices
This plugin uses the IOS native [PDFKit](https://developer.apple.com/documentation/pdfkit) to render
the pages of PDF files and provides a widget called `PDFKit` to display the PDF page you like.
