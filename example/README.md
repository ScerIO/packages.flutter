# flutter_pdf_renderer_example

Demonstrates how to use the flutter_pdf_renderer plugin.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_pdf_renderer_example/flutter_pdf_renderer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PdfRenderer example app'),
        ),
        body: PdfRenderer(pdfFile: 'assets/sample.pdf', width: 500.0),
      ),
    );
  }
}

```