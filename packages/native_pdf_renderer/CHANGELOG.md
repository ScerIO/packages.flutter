## 3.1.0

* Windows support [pull#174](https://github.com/rbcprolabs/packages.flutter/pull/174)

## 3.0.0 

* Resolved [issue#147](https://github.com/rbcprolabs/packages.flutter/issues/147), null-safety migration

## 2.4.0 

* Fixed [pull#131](https://github.com/rbcprolabs/packages.flutter/pull/131), rendering of landscape-orientation PDF files on iOS
* Fixed [pull#137](https://github.com/rbcprolabs/packages.flutter/pull/137), crash caused by invalid PDF format

## 2.3.2

* Fixed [issue#74](https://github.com/rbcprolabs/packages.flutter/issues/74), min ios version now 2 instead 11
* Fixed [issue#76](https://github.com/rbcprolabs/packages.flutter/issues/76), page width & height exception on web

## 2.3.1

* Fixed [issue#50](https://github.com/rbcprolabs/packages.flutter/issues/50)

## 2.3.0

* MacOs supported!

## 2.2.0

* Web supported!

## 2.1.1

* Update package `extension`

## 2.1.0

* Set minimal flutter version to 1.17.0

## 2.0.1

* Fixed [issue#60](https://github.com/rbcprolabs/packages.flutter/issues/60)

## 2.0.0

* Added more docs in readme
* Removed deprecated `PDFCropDef`, instead use `Rect`
* Renames:
  1. `PDFDocument` -> `PdfDocument`, 
  2. `PDFPage` -> `PdfPage`, 
  3. `PDFPageFormat` -> `PdfPageFormat`, 
  4. `PDFPageImage` -> `PdfPageImage`

## 1.8.1

* Fixed ios render crash [issue#29](https://github.com/rbcprolabs/packages.flutter/issues/29)

## 1.8.0

* Set minimal flutter version to 1.10
* Update synchronized package
* Fixed android build [issue#34](https://github.com/rbcprolabs/packages.flutter/issues/34)

## 1.7.0

* Fixed PDF crop on Android [pull#25](https://github.com/rbcprolabs/packages.flutter/pull/25))
* Added package synchronized for sequential access to the native api render to reduce the likelihood of a crash due to lack of memory. 
Additional information: [issue#14](https://github.com/rbcprolabs/packages.flutter/issues/14) & [issue#16](https://github.com/rbcprolabs/packages.flutter/issues/16)  

## 1.6.2

* Target sdk version for android upped to 28

## 1.6.1

* Added more tests
* Fixed `PDFPageImage.pageNumber` always returns `null`
* If page not in document throws `PdfPageNotFoundException`

## 1.6.0 

* Added more documentation for public properties and methods
* `crop` property in `render` method marked as deprecated, usage `cropRect` instead
* Added `isClosed` property for `PDFDocument` and `PDFPage`
* Added tests

## 1.5.0

* Added crop option for rendering (#11)
* Fixed bug with render same page from issue #5

## 1.4.2

* Fixed not correctly filling background Color on IOS

## 1.4.1

* Resolve supports Flutter v1.7

## 1.4.0+1

* Hotfix

## 1.4.0

* Now `format` and `backgroundColor` options for image rendering works on IOS.

## 1.3.0+1

* Hotfix

## 1.3.0

* Added `format` and `backgroundColor` options for image rendering.
  *Attention*: it feature works only on Android platform! 
* Added dart linter
* Refactoring existing code

## 1.2.3

* Scale fix on IOS

## 1.2.2

* Upgrade to Swift 5

## 1.2.1

* Fix IOS build error

## 1.2.0

* Optimized UI freezes on android platform

## 1.1.2

* Update readme

## 1.1.1

* Fix compilation error on pure android Java projects (#1)

## 1.1.0

* Transferred sources to `src` directory
* Removed `dispose` method from `PDFDocument` class (Replaced by `close` method) 
* Added more comments in code

## 1.0.1

* Fixed support capability dart v2.0 (non 2.1) by add import `dart:core` in files with use `Future`

## 1.0.0

* Initial release
