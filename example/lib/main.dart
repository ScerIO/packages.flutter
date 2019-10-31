import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:photo_view/photo_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  Future<File> createFileOfPdfUrl() async {
    final url = "http://www.pdf995.com/samples/pdf.pdf";
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  Widget pdfView(String path) {
    return NativePDFView(
      // pdfFile: 'assets/sample.pdf',
      // isAsset: true,
      isAsset: false,
      pdfFile: path,
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('NativePDFView example app'),
        ),
        body: Container(
          child: FutureBuilder(
            future: createFileOfPdfUrl(),
            builder: (_, AsyncSnapshot<File> snapshot) {
              if (snapshot.hasData) {
                return pdfView(snapshot.data.path);
              }

              return Center(child: CircularProgressIndicator(),);
            },
          ),
        ),
      ),
    );
  }
}
