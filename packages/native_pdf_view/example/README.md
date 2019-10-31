# native_pdv_view

Demonstrates how to use the flutter_pdf_renderer plugin.

```dart
import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:photo_view/photo_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('NativePDFView example app'),
        ),
        body: Container(
          child: NativePDFView(
            // Load from assets
            pdfFile: 'assets/sample.pdf',
            sAsset: true,
            // or load from file system
            // pdfFile: 'path/to/file',
            // isAsset: false,
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
        ),
      ),
    );
  }
}

```