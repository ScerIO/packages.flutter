import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:photo_view/photo_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('NativePDFView example app'),
          ),
          body: Container(
            child: NativePDFView(
              pdfFile: 'assets/sample.pdf',
              isAsset: true,
              pageBuilder: (imageFile) => PhotoView(
                imageProvider: FileImage(imageFile),
                initialScale: .40,
                maxScale: 1.75,
                minScale: .40,
                backgroundDecoration: BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
}
