> ## Plugin renamed and republished as `[pdfx]`
>
> [[pdfx] on pub.dev](https://pub.dev/packages/pdfx)
>
> Some smaller api changes
> 
>


Migration:
1. Replace dependencies
```diff
dependencies:
-   native_pdf_view: ^4.0.1
+   pdfx: ^1.0.0
```
2. Renamed `PdfPageFormat` -> `PdfPageImageFormat`
3. Re-case values `PdfPageImageFormat{JPEG,PNG,WEBP}` -> `PdfPageImageFormat{jpeg,png,webp}`

# native_pdf_view

`Flutter` Plugin to render PDF and show a PDF file on **Web**, **MacOs 10.11+**, **Android 5.0+**, **iOS** and **Windows**.

## Showcase

| Live                      | Screenshot                 |
|---------------------------|----------------------------|
|![](https://raw.githubusercontent.com/rbcprolabs/packages.flutter/master/packages/native_pdf_view/example/media/live.gif?raw=true)  | ![](https://raw.githubusercontent.com/rbcprolabs/packages.flutter/master/packages/native_pdf_view/example/media/screenshot.png?raw=true)  |


## Getting Started
[![pub package](https://img.shields.io/pub/v/native_pdf_view.svg)](https://pub.dev/packages/native_pdf_view)

In your flutter project add the dependency:
```shell
flutter pub add native_pdf_view
```

For web run tool for automatically add pdfjs library in index.html:
```shell
flutter pub run native_pdf_view:install_web
```

For windows run tool automatically add override for pdfium version property in CMakeLists.txt file:
```
flutter pub run native_pdf_view:install_web
```

## Usage example
It very simple!
```dart
import 'package:native_pdf_view/native_pdf_view.dart';

final pdfController = PdfController(
  document: PdfDocument.openAsset('assets/sample.pdf'),
);

Widget pdfView() => PdfView(
  controller: pdfController,
);
```

Package usage [[pdf_renderer]](https://pub.dev/packages/pdf_renderer) and supports her api:

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

## Api

### PdfController

| Parameter        | Description                                                | Default |
|------------------|------------------------------------------------------------|---------|
| document         | The document to be displayed                               | -       |
| initialPage      | The page to show when first creating the  [PdfView]        | 1       |
| viewportFraction | The fraction of the viewport that each page should occupy. | 1.0     |

### PdfView

| Parameter        | Description                                                                                                    | Default                                                                                                 |
|------------------|----------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| controller       | Pages control. See [page control](#page-control) and  [additional pdf info](#additional-pdf-info)              | -                                                                                                       |
| onPageChanged    | Called whenever the page in the center of the viewport changes.  See [Document callbacks](#document-callbacks) | -                                                                                                       |
| onDocumentLoaded | Called when a document is loaded. See [Document callbacks](#document-callbacks)                                | -                                                                                                       |
| onDocumentError  | Called when a document loading error. Exception is passed in the attributes                                    | -                                                                                                       |
| documentLoader   | Widget showing when pdf document loading                                                                       | SizedBox()                                                                                              |
| pageLoader       | Widget showing when pdf page loading                                                                           | SizedBox()                                                                                              |
| builder          | Callback called to render a widget for each page. See [custom page builder](#custom-page-builder)              | Default builder                                                                                         |
| errorBuilder     | Show document loading error message inside  `PdfView`                                                          | Centered error text                                                                                     |
| renderer         | Custom PdfRenderer library options.  See [custom renderer options](#custom-renderer-options)                   | width: page.width * 2<br>height: page.height * 2<br>format: PdfPageFormat.JPEG<br>backgroundColor: '#ffffff' |
| scrollDirection  | Page turning direction                                                                                         | Axis.horizontal                                                                                       |                                                                                |
| physics          | How the widgets should respond to user input                                                                   | -                                                                                                       |
| pageSnapping     | Set to false for mouse wheel scroll on web                                                                     | true                                                                                                    |

## Additional examples

### Open another document
```dart
pdfController.openDocument(PdfDocument.openAsset('assets/sample.pdf'));
```

### Page control:
```dart
// Jump to specified page
pdfController.jumpTo(3);

// Animate to specified page
_pdfController.animateToPage(3, duration: Duration(milliseconds: 250), curve: Curves.ease);

// Animate to next page 
_pdfController.nextPage(duration: Duration(milliseconds: 250), curve: Curves.easeIn);

// Animate to previous page
_pdfController.previousPage(duration: Duration(milliseconds: 250), curve: Curves.easeOut);
```

### Additional pdf info:
```dart
// Actual showed page
pdfController.page;

// Count of all pages in document
pdfController.pagesCount;
```

### Document callbacks
```dart
int _actualPageNumber = 0, _allPagesCount = 0;

PdfView(
  controller: pdfController,
  onDocumentLoaded: (document) {
    setState(() {
      _allPagesCount = document.pagesCount;
    });
  },
  onPageChanged: (page) {
    setState(() {
      _actualPageNumber = page;
    });
  },
);

/// Now you can use these values to display the reading status of the document.
Text('Read: $_actualPageNumber of $_allPagesCount');
```

### Custom renderer options
```dart
PdfView(
  controller: pdfController,
  renderer: (PdfPage page) => page.render(
    width: page.width * 2,
    height: page.height * 2,
    format: PdfPageFormat.JPEG,
    backgroundColor: '#FFFFFF',
  ),
);
```

### Custom page builder:
```dart
PdfView(
  controller: pdfController,
  document: snapshot.data,
  pageBuilder: (
    Future<PdfPageImage> pageImage,
    int index,
    PdfDocument document,
  ) => PhotoViewGalleryPageOptions(
      imageProvider: PdfPageImageProvider(
        pageImage,
        index,
        document.id,
      ),
      minScale: PhotoViewComputedScale.contained * 1,
      maxScale: PhotoViewComputedScale.contained * 3.0,
      initialScale: PhotoViewComputedScale.contained * 1.0,
      heroAttributes: PhotoViewHeroAttributes(tag: '${document.id}-$index'),
    ),
);
```

## Rendering additional info

### On Web
This plugin uses the [PDF.js](https://mozilla.github.io/pdf.js/)

### On Android
This plugin uses the Android native [PdfRenderer](https://developer.android.com/reference/android/graphics/pdf/PdfRenderer)

### On Ios & MacOs
This plugin uses the IOS native [CGPDFPage](https://developer.apple.com/documentation/coregraphics/cgpdfdocument/cgpdfpage)

### On Windows
This plugin use [PDFium](https://pdfium.googlesource.com/pdfium/+/master/README.md)
