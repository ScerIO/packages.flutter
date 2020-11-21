# native_pdv_view

Demonstrates how to use the flutter_pdf_renderer plugin.

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Future<PdfDocument> _getDocument() async {
    if (await (hasSupport)) {
      return PdfDocument.openAsset('assets/sample.pdf');
    }

    throw Exception(
      'PDF Rendering does not '
      'support on the system of this version',
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(primaryColor: Colors.white),
        home: Scaffold(
          appBar: AppBar(title: Text('PDFView example')),
          body: FutureBuilder<PdfDocument>(
            future: _getDocument(),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return PDFView(
                  document: snapshot.data,
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'PDF Rendering does not '
                    'support on the system of this version',
                  ),
                );
              }

              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      );
}
```
