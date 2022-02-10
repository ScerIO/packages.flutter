# Example of usage `pdf_renderer`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdf_renderer.dart';

void main() async {
  try {
    final document = await PdfDocument.openAsset('assets/sample.pdf');

    // Or open from data:
    // final document = await PdfDocument.openData(<Uint8List>);

    // Or open from file path:
    // final document = await PdfDocument.openFile('absolute/path/to/file');


    final page = await document.getPage(1); // Not index! Page number starts from 1

    final pageImage = await page.render(width: page.width, height: page.height);
    // You can increase image quality:
    // final pageImage = await page.render(width: page.width * 3, height: page.height * 3);

    // Before open another page it is necessary to close the previous
    // The android platform does not allow parallel rendering
    await page.close();

    final page2 = await document.getPage(2);
    final page2Image = await page2.render(width: page2.width, height: page2.height);
    await page2.close();
    runApp(
      MaterialApp(
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
            ),
          ),
        ),
        // Images are rendered with an alpha channel. 
        // White background is needed for black tex to be seen.
        color: Colors.white,
      )
    );
  } on PlatformException catch (error) {
    // Handle render error
    print(error);
  }
}
```
