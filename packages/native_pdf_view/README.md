# native_pdf_view

`Flutter` Plugin to render PDF and show a PDF file on **Web**, **MacOs 10.11+**, **Android 5.0+** and **iOS**.

## Showcase

| Live                      | Screenshot                 |
|---------------------------|----------------------------|
|![](https://raw.githubusercontent.com/rbcprolabs/packages.flutter/master/packages/native_pdf_view/example/media/live.gif?raw=true)  | ![](https://raw.githubusercontent.com/rbcprolabs/packages.flutter/master/packages/native_pdf_view/example/media/screenshot.png?raw=true)  |


## Getting Started
In your flutter project add the dependency:

[![pub package](https://img.shields.io/pub/v/native_pdf_view.svg)](https://pub.dev/packages/native_pdf_view)

```yaml
dependencies:
  native_pdf_view: any
```

For web add lines in index.html before importing main.dart.js:
```html
<script src="//cdnjs.cloudflare.com/ajax/libs/pdf.js/2.4.456/pdf.min.js"></script>
<script type="text/javascript">
  pdfjsLib.GlobalWorkerOptions.workerSrc = "//cdnjs.cloudflare.com/ajax/libs/pdf.js/2.4.456/pdf.worker.min.js";
</script>
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
