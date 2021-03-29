# PDF Renderer

`Flutter` Plugin to render PDF pages as images on **Web**, **MacOs 10.11+**, **Android 5.0+**, **iOS** and **Windows**.

**We also support the package for easy display PDF documents [native_pdf_view](https://pub.dev/packages/native_pdf_view)**

## Getting Started
In your flutter project add the dependency:

[![pub package](https://img.shields.io/pub/v/native_pdf_renderer.svg)](https://pub.dartlang.org/packages/native_pdf_renderer)

```yaml
dependencies:
  native_pdf_renderer: any
```

For web add lines in index.html before importing main.dart.js:
```html
<script src="//cdnjs.cloudflare.com/ajax/libs/pdf.js/2.4.456/pdf.min.js"></script>
<script type="text/javascript">
  pdfjsLib.GlobalWorkerOptions.workerSrc = "//cdnjs.cloudflare.com/ajax/libs/pdf.js/2.4.456/pdf.worker.min.js";
</script>
```

## Usage example

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';

void main() async {
  try {
    final document = await PdfDocument.openAsset('assets/sample.pdf');
    final page = await document.getPage(1);
    final pageImage = await page.render(width: page.width, height: page.height);
    await page.close();
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Image(
              image: MemoryImage(pageImage.bytes),
            ),
          ),
        ),
        color: Colors.white,
      )
    );
  } on PlatformException catch (error) {
    print(error);
  }
}
```

## Api

### PdfDocument

| Parameter  | Description                                                                                | Default |
|------------|--------------------------------------------------------------------------------------------|---------|
| sourceName | Needed for toString method. Contains a method for opening a document (file, data or asset) | -       |
| id         | Document unique id. Generated when opening document.                                       | -       |
| pagesCount | All pages count in document. Starts from 1.                                                | -       |
| isClosed   | Is the document closed                                                                     | -       |

**Document open:**
```dart
// From assets (Android, Ios, MacOs, Web)
PdfDocument.openAsset('assets/sample.pdf')

// From file (Android, Ios, MacOs)
PdfDocument.openFile('path/to/file/on/device')

// From data (Android, Ios, MacOs, Web)
PdfDocument.openData(uint8Data)
```

**Open page:**
```dart
final page = document.getPage(pageNumber); // Starts from 1
```

**Close document:**
```dart
document.close();
```

### PdfPage

| Parameter | Description                                                                         | Default |
|-----------|-------------------------------------------------------------------------------------|---------|
| document  | Parent document                                                                     | Parent  |
| id        | Page unique id. Needed for rendering and closing page. Generated when opening page. | -       |
| width     | Page source width in pixels, int                                                    | -       |
| height    | Page source height in pixels, int                                                   | -       |
| isClosed  | Is the page closed                                                                  | false   |

**Render image:**
```dart
final pageImage = page.render(
  // rendered image width resolution, required
  width: page.width * 2,
  // rendered image height resolution, required
  height: page.height * 2,

  // Rendered image compression format, also can be PNG, WEBP*
  // Optional, default: PdfPageFormat.PNG
  // Web not supported
  format: PdfPageFormat.JPEG,

  // Image background fill color for JPEG
  // Optional, default '#ffffff'
  // Web not supported
  backgroundColor: '#ffffff',

  // Crop rect in image for render
  // Optional, default null
  // Web not supported
  cropRect: Rect.fromLTRB(left, top, right, bottom),
);
```

### PdfPageImage

| Parameter  | Description                                                                        | Default           |
|------------|------------------------------------------------------------------------------------|-------------------|
| id         | Page unique id. Needed for rendering and closing page. Generated when render page. | -                 |
| pageNumber | Page number. The first page is 1.                                                  | -                 |
| width      | Width of the rendered area in pixels, int                                          | -                 |
| height     | Height of the rendered area in pixels, int                                         | -                 |
| bytes      | Rendered image result, Uint8List                                                   | -                 |
| format     | Rendered image compression format, for web always PNG                              | PdfPageFormat.PNG |

```dart

```

**Close page:**
<br>
Before open new page android asks to close the past. <br>
If this is not done, the application may crash with an error
```dart
page.close();
```

\* __PdfPageFormat.WEBP support only on android__

## Rendering additional info

### On Web
This plugin uses the [PDF.js](https://mozilla.github.io/pdf.js/)

### On Android
This plugin uses the Android native [PdfRenderer](https://developer.android.com/reference/android/graphics/pdf/PdfRenderer)

### On Ios & MacOs
This plugin uses the IOS native [CGPDFPage](https://developer.apple.com/documentation/coregraphics/cgpdfdocument/cgpdfpage)

### On Windows
This plugin use [PDFium](https://pdfium.googlesource.com/pdfium/+/master/README.md)
