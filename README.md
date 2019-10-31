# PDF Renderer

`Flutter` Plugin to render PDF pages as images on both Android 5+ and iOS devices.
#### Implementation of support for andgpoid 4.4 in plans

## Getting Started
In your flutter project add the dependency:

[![pub package](https://img.shields.io/pub/v/native_pdf_renderer.svg)](https://pub.dartlang.org/packages/native_pdf_renderer)

```dart
dependencies:
  ...
  native_pdf_renderer: any
```
For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## Usage example
[Read more](./example/README.md)
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';

void main() async {
  try {
    final document = await PDFDocument.openAsset('assets/sample.pdf');
    final page = await document.getPage(1);
    final pageImage = await page.render(width: page.width, height: page.height);
    await page.close();
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            Image(
              image: MemoryImage(pageImage.bytes),
            ),
          ),
        ),
        color: Colors.white,
      )
    );
  } on PlatformException catch (error) {
    print(error);
  }
}
```

## Rendering PDF files on Android devices
Use the provided widget `PdfRenderer` in order to render a PDF file.
This plugin uses the Android native [PdfRenderer](https://developer.android.com/reference/android/graphics/pdf/PdfRenderer) to render
the pages of PDF files and provides a widget called `PdfRenderer` to display the PDF page you like.
