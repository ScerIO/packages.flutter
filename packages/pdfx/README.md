# PDFx

`Flutter` Plugin to render & show PDF pages as images on **Web**, **MacOs 10.11+**, **Android 5.0+**, **iOS** and **Windows**.

**We also support the package for easy display PDF documents [pdfx](https://pub.dev/packages/pdfx)**

[![pub package](https://img.shields.io/pub/v/pdfx.svg)](https://packages/pdfx)

## Showcase

| Live                      | Screenshot                 |
|---------------------------|----------------------------|
|![](https://raw.githubusercontent.com/rbcprolabs/packages.flutter/master/packages/native_pdf_view/example/media/live.gif?raw=true)  | ![](https://raw.githubusercontent.com/rbcprolabs/packages.flutter/master/packages/native_pdf_view/example/media/screenshot.png?raw=true)  |

## Getting Started
In your flutter project add the dependency:
```shell
flutter pub add pdfx
```

For web run tool for automatically add pdfjs library in index.html:
```shell
flutter pub run pdfx:install_web
```

For windows run tool automatically add override for pdfium version property in CMakeLists.txt file:
```
flutter pub run pdfx:install_web
```

## Usage example

```dart
import 'package:pdfx/pdfx.dart';

final pdfController = PdfController(
  document: PdfDocument.openAsset('assets/sample.pdf'),
);

Widget pdfView() => PdfViewPinch(
  controller: pdfController,
);
```

## Api

### PdfDocument

| Parameter  | Description                                                                                | Default |
|------------|--------------------------------------------------------------------------------------------|---------|
| sourceName | Needed for toString method. Contains a method for opening a document (file, data or asset) | -       |
| id         | Document unique id. Generated when opening document.                                       | -       |
| pagesCount | All pages count in document. Starts from 1.                                                | -       |
| isClosed   | Is the document closed                                                                     | -       |

**Local document open:**
```dart
// From assets (Android, Ios, MacOs, Web)
PdfDocument.openAsset('assets/sample.pdf')

// From file (Android, Ios, MacOs)
PdfDocument.openFile('path/to/file/on/device')

// From data (Android, Ios, MacOs, Web)
PdfDocument.openData((FutureOr<Uint8List>) data)
```
**Network document open:**

Install [[network_file]](https://pub.dev/packages/internet_file) package (supports all platforms):
```shell
flutter pub add internet_file
```

And use it
```dart
import 'package:internet_file/internet_file.dart';

PdfDocument.openData(InternetFile.get('https://github.com/rbcprolabs/packages.flutter/raw/fd0c92ac83ee355255acb306251b1adfeb2f2fd6/packages/native_pdf_renderer/example/assets/sample.pdf'))
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
  // Optional, default: PdfPageImageFormat.PNG
  // Web not supported
  format: PdfPageImageFormat.JPEG,

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
| format     | Rendered image compression format, for web always PNG                              | PdfPageImageFormat.PNG |

**Close page:**
<br>
Before open new page android asks to close the past. <br>
If this is not done, the application may crash with an error
```dart
page.close();
```

\* __PdfPageImageFormat.WEBP support only on android__

## Rendering additional info

### On Web
This plugin uses the [PDF.js](https://mozilla.github.io/pdf.js/)

### On Android
This plugin uses the Android native [PdfRenderer](https://developer.android.com/reference/android/graphics/pdf/PdfRenderer)

### On Ios & MacOs
This plugin uses the iOS & MacOs native [CGPDFPage](https://developer.apple.com/documentation/coregraphics/cgpdfdocument/cgpdfpage)

### On Windows
This plugin uses [PDFium](https://pdfium.googlesource.com/pdfium/+/master/README.md)
