## 4.0.1

* Fixed [issue#170](https://github.com/rbcprolabs/packages.flutter/issues/170), 4.0.0 not works

## 4.0.0

* Null safety migration & Flutter v2 capability
* Added `PdfPageImageProvider`
* Package `[extended_image]` replaced by `[photo_view]`
* Break changes at `pageBuilder` callback (`PDFViewPageBuilder`)
* Added `<BoxDecoration> backgroundDecoration` property at `PdfView`
* Added optional `initialPage` property in `PdfController.loadDocument()`
* Temporarily disabled `pageSnapping` option

## 3.9.1

* Fixed [issue#119](https://github.com/rbcprolabs/packages.flutter/issues/119), Initial page isn't working 
* Update dependency `extended_image`

## 3.9.0

* Upgrade dependencies

## 3.8.0

* Upgrade dependencies

## 3.7.0

* Added `initialPage` in `PdfController.loadDocument` method [issue#89](https://github.com/rbcprolabs/packages.flutter/issues/89)
* Fixed crash when switching between pdf [issue#93](https://github.com/rbcprolabs/packages.flutter/issues/93)

## 3.6.2

* Fixed [issue#78](https://github.com/rbcprolabs/packages.flutter/issues/78), loadDocument in PdfController not working

## 3.6.1

* Fixed [issue#74](https://github.com/rbcprolabs/packages.flutter/issues/74), min ios version now 2 instead 11
* Fixed [issue#76](https://github.com/rbcprolabs/packages.flutter/issues/76), page width & height exception on web
* Update dependency `extended_image`

## 3.6.0

* Fixed `errorBuilder` (usage object as type instead Exception)
* Added option `loaderSwitchDuration`
* Fixed readme

## 3.5.2

* Fixed error handle [issue#71](https://github.com/rbcprolabs/packages.flutter/issues/71)

## 3.5.1

* Update dependency `extended_image`

## 3.5.0+1

* Docs improvement

## 3.5.0

* Scroll with mouse wheel for web [issue#69](https://github.com/rbcprolabs/packages.flutter/issues/69)

## 3.4.0

* MacOs supported!

## 3.3.0

* Web supported!

## 3.2.1

* Fixed [issue#65](https://github.com/rbcprolabs/packages.flutter/issues/65) `PdfController.jumpToPage`

## 3.2.0

* Set minimal flutter version to 1.17.0

## 3.2.0-dev.1

* Adapted 3.1.0 for flutter sdk > 1.16.0

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
