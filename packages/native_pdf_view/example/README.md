# native_pdv_view

Demonstrates how to use the flutter_pdf_renderer plugin.

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';

import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:native_pdf_view_example/has_support.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {


  Future<PDFDocument> _getDocument() async {
    if (await _hasSupportPdfRendering()) {
      return PDFDocument.openAsset('assets/sample.pdf');
    } else {
      throw Exception(
        'PDF Rendering does not '
        'support on the system of this version',
      );
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(primaryColor: Colors.white),
        home: Scaffold(
          appBar: AppBar(title: Text('PDFView example')),
          body: FutureBuilder<PDFDocument>(
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

Future<bool> _hasSupportPdfRendering() async {
  final deviceInfo = DeviceInfoPlugin();
  bool hasSupport = false;
  if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    hasSupport = int.parse(iosInfo.systemVersion.split('.').first) >= 11;
  } else if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    hasSupport = androidInfo.version.sdkInt >= 21;
  }
  return hasSupport;
}
```
