import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:native_pdf_view_example/has_support.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Future<PDFDocument> _getDocument() async {
    if (await hasSupport()) {
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
