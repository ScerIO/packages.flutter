import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'pdf_renderer.dart';

/// Displays the pages of a [pdfFile] stored on the device.
class NativePDFView extends StatelessWidget {
  final Widget loader;
  final String pdfFile;
  final bool isAsset;
  final Widget Function(File imageFile) pageBuilder;

  NativePDFView({
    this.loader,
    @required this.pdfFile,
    this.isAsset = false,
    @required this.pageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PDFRenderer.renderPdf(pdfFile: pdfFile, isAsset: isAsset),
      builder: (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
        if (snapshot.hasData)
          return PageView(
            children: snapshot.data.map(pageBuilder).toList(),
          );

        return loader ??
            Center(
              child: CircularProgressIndicator(),
            );
      },
    );
  }
}
