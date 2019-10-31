# native_pdf_view

Flutter Plugin to render a PDF file. Supports both Android and iOS.

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
Use the provided widget `PdfRenderer` in order to render a PDF file.
This plugin uses the Android native [PdfRenderer](https://developer.android.com/reference/android/graphics/pdf/PdfRenderer) to render
the pages of PDF files and provides a widget called `PdfRenderer` to display the PDF page you like.
