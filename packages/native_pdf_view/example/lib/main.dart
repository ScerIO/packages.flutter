import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

enum DocumentType { DUMMY, SAMPLE, ERROR }

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _actualPageNumber = 1, _allPagesCount = 0;
  DocumentType documentType;
  PdfController _pdfController;

  @override
  void initState() {
    _pdfController = PdfController(
      document: PdfDocument.openAsset('assets/sample.pdf'),
    );
    super.initState();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(primaryColor: Colors.white),
        home: Scaffold(
          appBar: AppBar(
            title: Text('PdfView example'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.navigate_before),
                onPressed: () {
                  _pdfController.previousPage(
                    curve: Curves.ease,
                    duration: Duration(milliseconds: 100),
                  );
                },
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  '$_actualPageNumber/$_allPagesCount',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              IconButton(
                icon: Icon(Icons.navigate_next),
                onPressed: () {
                  _pdfController.nextPage(
                    curve: Curves.ease,
                    duration: Duration(milliseconds: 100),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  if (documentType == DocumentType.DUMMY) {
                    _pdfController.loadDocument(
                        PdfDocument.openAsset('assets/dummy.pdf'));
                    documentType = DocumentType.SAMPLE;
                  } else if (documentType == DocumentType.SAMPLE) {
                    _pdfController.loadDocument(
                        PdfDocument.openAsset('assets/sample.pdf'));
                    documentType = DocumentType.ERROR;
                  } else {
                    _pdfController
                        .loadDocument(PdfDocument.openAsset('xxxxxx'));
                    documentType = DocumentType.DUMMY;
                  }
                },
              )
            ],
          ),
          body: PdfView(
            errorBuilder: (e) => Container(
              color: Colors.red[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Error',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            errorPadding: const EdgeInsets.all(16),
            documentLoader: Center(child: CircularProgressIndicator()),
            pageLoader: Center(child: CircularProgressIndicator()),
            controller: _pdfController,
            onDocumentLoaded: (document) {
              setState(() {
                _actualPageNumber = 1;
                _allPagesCount = document.pagesCount;
              });
            },
            onPageChanged: (page) {
              setState(() {
                _actualPageNumber = page;
              });
            },
          ),
        ),
      );
}
