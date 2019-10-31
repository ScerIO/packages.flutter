import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';

void main() async {
  try {
    final document = await PDFDocument.openAsset('assets/sample.pdf');
    final page = await document.getPage(1);
    final pageImage =
        await page.render(width: page.width * 2, height: page.height * 2);
    await page.close();
    final page2 = await document.getPage(2);
    final page2Image =
        await page2.render(width: page2.width * 2, height: page2.height * 2);
    await page2.close();
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
            child: PageView(
          children: <Widget>[
            Image(
              image: MemoryImage(pageImage.bytes),
            ),
            Image(
              image: MemoryImage(page2Image.bytes),
            )
          ],
        )),
      ),
      color: Colors.white,
    ));
  } on PlatformException catch (error) {
    print(error);
  }
}
