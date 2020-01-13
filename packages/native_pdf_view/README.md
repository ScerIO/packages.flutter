# native_pdf_view

`Flutter` Plugin to render PDF and show a PDF file on both **Android 5.0+** and **iOS 11.0+** devices.
## Getting Started
In your flutter project add the dependency:

[![pub package](https://img.shields.io/pub/v/native_pdf_view.svg)](https://pub.dev/packages/native_pdf_view)

```yaml
dependencies:
  native_pdf_view: any
```
For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## Usage example
It very simple!
```dart
import 'package:native_pdf_view/native_pdf_view.dart';

Widget pdfView() => FutureBuilder<PDFDocument>(
  // Open document
  future: PDFDocument.openAsset('assets/sample.pdf'),
  builder: (_, snapshot) {
    if (snapshot.hasData) {
      // Show document
      return PDFView(document: snapshot.data);
    }

    if (snapshot.hasError) {
      // Catch 
      return Center(
        child: Text(
          'PDF Rendering does not '
          'support on the system of this version',
        ),
      );
    }

    return Center(child: CircularProgressIndicator());
  },
);
```

Initial page:
```dart
final pageController = PageController(
  initialPage: 3,
);

PDFView(
  controller: pageController,
  document: snapshot.data,
);
```

Custom renderer options
```dart
PDFView(
  controller: pageController,
  renderer: (PDFPage page) => page.render(
    width: page.width * 2,
    height: page.height * 2,
    format: PDFPageFormat.JPEG,
    backgroundColor: '#ffffff',
  ),
);
```

Custom page builder:
```dart
PDFView.builder(
  controller: pageController,
  document: snapshot.data,
  builder: (PDFPageImage pageImage, bool isCurrentIndex) {
    Widget image = ExtendedImage.memory(
      pageImage.bytes,
      fit: BoxFit.fitWidth,
      mode: ExtendedImageMode.gesture,
      initGestureConfigHandler: (_) => GestureConfig(
        minScale: 1,
        animationMinScale: .75,
        maxScale: 2,
        animationMaxScale: 2.5,
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

        if (begin == _doubleTapScales[0]) {
          end = _doubleTapScales[1];
        } else {
          end = _doubleTapScales[0];
        }

        state.handleDoubleTap(
          scale: end,
          doubleTapPosition: pointerDownPosition,
        );
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

## Rendering PDF files on Android devices
This plugin uses the Android native [PdfRenderer](https://developer.android.com/reference/android/graphics/pdf/PdfRenderer) to render
the pages of PDF files and provides a widget called `PdfRenderer` to display the PDF page you like.

## Rendering PDF files on IOS devices
This plugin uses the IOS native [PDFKit](https://developer.apple.com/documentation/pdfkit) to render
the pages of PDF files and provides a widget called `PDFKit` to display the PDF page you like.
