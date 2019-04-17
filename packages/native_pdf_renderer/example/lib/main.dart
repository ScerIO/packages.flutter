import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final storage = PagesStorage();

    return MaterialApp(
      title: 'PDF View example',
      color: Colors.white,
      home: Scaffold(
        body: FutureBuilder(
          future: PDFDocument.openAsset('assets/sample.pdf'),
          builder: (context, AsyncSnapshot<PDFDocument> snapshot) {
            if (!snapshot.hasData || snapshot.hasError)
              return Center(
                child: CircularProgressIndicator(),
              );

            return PageView(
              children: <Widget>[
                ImageLoader(
                  storage: storage,
                  document: snapshot.data,
                  pageNumber: 1,
                ),
                ImageLoader(
                  storage: storage,
                  document: snapshot.data,
                  pageNumber: 2,
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomAppBar(
            child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Swipe to right',
                style: Theme.of(context).textTheme.title,
              ),
              Icon(Icons.keyboard_arrow_right)
            ],
          ),
        )),
      ),
    );
  }
}

class PagesStorage {
  final Map<int, PDFPageImage> pages = {};
}

class ImageLoader extends StatelessWidget {
  ImageLoader({
    Key key,
    @required this.storage,
    @required this.document,
    @required this.pageNumber,
  }) : super(key: key);

  final PagesStorage storage;
  final PDFDocument document;
  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _renderPage(),
      builder: (context, AsyncSnapshot<PDFPageImage> snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Text('Error'),
          );
        if (!snapshot.hasData)
          return Center(
            child: CircularProgressIndicator(),
          );

        return Image(
          image: MemoryImage(snapshot.data.bytes),
        );
      },
    );
  }

  Future<PDFPageImage> _renderPage() async {
    if (storage.pages.containsKey(pageNumber)) return storage.pages[pageNumber];
    final page = await document.getPage(pageNumber);
    final format = Platform.isIOS ? PDFPageFormat.PNG : PDFPageFormat.JPEG;
    final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: format,
        backgroundColor: '#ffffff');
    await page.close();
    storage.pages[pageNumber] = pageImage;
    return pageImage;
  }
}
