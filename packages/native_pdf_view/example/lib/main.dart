import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:native_pdf_view_example/has_support.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _actualPageNumber = 1;
  PDFDocument _document;

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(primaryColor: Colors.white),
        home: Scaffold(
          appBar: AppBar(title: Text('PDFView example')),
          body: FutureBuilder<PDFDocument>(
            future: _getDocument(),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return Stack(
                  children: <Widget>[
                    PDFView(
                      document: snapshot.data,
                      onPageChanged: (page) {
                        setState(() {
                          _actualPageNumber = page;
                        });
                      },
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '$_actualPageNumber/${snapshot.data.pagesCount}',
                        style: TextStyle(fontSize: 34),
                      ),
                    )
                  ],
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

  Future<PDFDocument> _getDocument() async {
    if (_document != null) {
      return _document;
    }
    if (await hasSupport()) {
      return _document = await PDFDocument.openAsset('assets/sample.pdf');
    } else {
      throw Exception(
        'PDF Rendering does not '
        'support on the system of this version',
      );
    }
  }
}
