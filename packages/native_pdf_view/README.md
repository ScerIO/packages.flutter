# native_pdf_view

`Flutter` Plugin to render PDF and show a PDF file on **Web**, **Android 5.0+** and **iOS 11.0+** devices.

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
| renderer         | Custom PdfRenderer library options.  See [custom renderer options](#custom-renderer-options)                   | width: page.width * 2,<br>height: page.height * 2,<br>format: PdfPageFormat.JPEG,<br>backgroundColor: '#ffffff', |
| scrollDirection  | Page turning direction                                                                                         | Axis . horizontal                                                                                       |                                                                                |

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
PdfView.builder(
  controller: pdfController,
  document: snapshot.data,
  builder: (
    PdfPageImage pageImage, 
    bool isCurrentIndex, 
    AnimationController animationController,
  ) {
    // Double tap scales
    final List<double> _doubleTapScales = <double>[1.0, 2.0, 3.0]
    // Double tap animation
    Animation<double> _doubleTapAnimation;
    void Function() _animationListener;

    Widget image = ExtendedImage.memory(
      pageImage.bytes,
      key: Key(pageImage.hashCode.toString()),
      fit: BoxFit.contain,
      mode: ExtendedImageMode.gesture,
      initGestureConfigHandler: (_) => GestureConfig(
        minScale: 1,
        maxScale: 3.0,
        animationMinScale: .75,
        animationMaxScale: 3.0,
        speed: 1,
        inertialSpeed: 100,
        inPageView: true,
        initialScale: 1.0,
        cacheGesture: false,
      ),
      onDoubleTap: (ExtendedImageGestureState state) {
        final pointerDownPosition = state.pointerDownPosition;
        final begin = state.gestureDetails.totalScale;
        double end;

        _doubleTapAnimation?.removeListener(_animationListener);

        animationController
          ..stop()
          ..reset();

        if (begin == _doubleTapScales[0]) {
          end = _doubleTapScales[1];
        } else {
          if (begin == _doubleTapScales[1]) {
            end = _doubleTapScales[2];
          } else {
            end = _doubleTapScales[0];
          }
        }

        _animationListener = () {
          //print(_animation.value);
          state.handleDoubleTap(
              scale: _doubleTapAnimation.value,
              doubleTapPosition: pointerDownPosition);
        };
        _doubleTapAnimation = animationController
            .drive(Tween<double>(begin: begin, end: end))
              ..addListener(_animationListener);

        animationController.forward();
      },
    );
    if (isCurrentIndex) {
      image = Hero(
        tag: 'pdf_view' + pageImage.pageNumber.toString(),
        child: image,
      );
    }
    return image;
  },
);
```

## Rendering additional info

### rendering on Web
This plugin uses the [PDF.js](https://mozilla.github.io/pdf.js/)

### Rendering on Android devices
This plugin uses the Android native [PdfRenderer](https://developer.android.com/reference/android/graphics/pdf/PdfRenderer)

### Rendering on IOS devices
This plugin uses the IOS native [PDFKit](https://developer.apple.com/documentation/pdfkit)
