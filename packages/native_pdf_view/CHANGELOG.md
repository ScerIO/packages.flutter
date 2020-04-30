## 3.1.0

* Added `pageSnapping`, `physics` [issue#58](https://github.com/rbcprolabs/packages.flutter/issues/58)
* Fixed `errorBuilder`

## 3.1.0-dev.2

* Adapted 3.0.1 for flutter sdk > 1.16.0

## 3.0.1

* Fixed issues: [issue#57](https://github.com/rbcprolabs/packages.flutter/issues/57), [issue#55](https://github.com/rbcprolabs/packages.flutter/issues/55) 

## 3.1.0-dev.1

* Fix build error on high flutter sdk (> 1.16.0)

## 3.0.0

* Added more docs & examples in readme
* Fixed [issue#54](https://github.com/rbcprolabs/packages.flutter/issues/54), [issue#39](https://github.com/rbcprolabs/packages.flutter/issues/39)
* `render` property work fixed
* Renamed `PDFView` to `PdfView`
* Removed constructor `PDFView.builder`, `builder` property now available in `PdfView` constructor
* Added double tap animation, a
* Added third step for  double tap
* Added `PdfController`, document loading now happens through it
* Property `controller` now requires `PdfController` instead `PageController` (methods and properties 
from `PageController` saved in `PdfController`)
* `loader` property replaced to `documentLoader` and `pageLoader`
* Added properties:
  1. onDocumentLoaded(PdfDocument document) - calls on document loaded
  2. onDocumentError(Exception error) - calls on loading document error
  3. Widget errorBuilder(Exception error) - show document loading error in PdfView
* In `PDFViewPageBuilder` (`builder` property) added `animationController` argument for animate double tap
* Updated `[extended_image]` package

## 2.3.0-dev.1

* Fix build error on high flutter sdk (> 1.16.0)

## 2.2.0

* Set minimal flutter version to 1.10
* Upgrade packages
* Fixed bugs with crashes [issue#14](https://github.com/rbcprolabs/packages.flutter/issues/14), [issue#16](https://github.com/rbcprolabs/packages.flutter/issues/16)

## 2.1.1

* Target sdk version for android upped to 28

## 2.1.0

* Added `onPageChanged` callback

## 2.0.0

* Removed default padding

## 2.0.0-dev.1
* Rewritten again with using package `[native_pdf_renderer]`
* Usage `[extended_image]` instead `[photo_view]`
* Optimized page rendering speed

## 1.0.2

* Update example readme

## 1.0.1

* Fix package details

## 1.0.0

* Initial release
