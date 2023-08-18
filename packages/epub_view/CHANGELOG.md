## 3.2.0

* Upgrade epubx dependency

## 3.1.0

* Upgrade dependencies

## 3.0.0

* Refactored code
* Removed `rxdart` dependency
* Renamed widgets:
```diff
-EpubActualChapter
+EpubViewActualChapter

-EpubReaderTableOfContents
+EpubViewTableOfContents
```
* New custom builders api. Example: 
```dart
EpubView(
  builders: EpubViewBuilders<DefaultBuilderOptions>(
    options: const DefaultBuilderOptions(
      loaderSwitchDuration: const Duration(seconds: 1),
      transitionBuilder: SomeWidget.transitionBuilder,
      chapterPadding: const EdgeInsets.all(8),
      paragraphPadding: const EdgeInsets.symmetric(horizontal: 16),
      textStyle: const TextStyle(
        height: 1.25,
        fontSize: 16,
      ),
    ),
    chapterBuilder: SomeWidget.chapterBuilder,
    chapterDividerBuilder: (_) => const Divider(),
    loaderBuilder: (_) =>
        const Center(child: CircularProgressIndicator()),
    errorBuilder: (_, error) => Center(child: Text(error.toString())),
    builder: SomeWidget.builder,
  ),
)
```
* New document loader api. Example:
```dart
// and load from assets
EpubDocument.openAsset('assets/book.epub');

// load from memory
EpubDocument.openData(Uint8List);

// load from file
EpubDocument.openFile(File);

// and load from internet
import 'package:internet_file/internet_file.dart';

// The cors policy is required on the server. 
// You can raise your cors proxy.
PdfDocument.openData(InternetFile.get('https://link.to/book.epub'))
```
Migration: 
```diff
- import 'package:flutter/services.dart' show rootBundle;
- 
- Future<Uint8List> _loadFromAssets(String assetName) async {
-  final bytes = await rootBundle.load(assetName);
-  return bytes.buffer.asUint8List();
- }

_epubController = EpubController(
-   document: EpubReader.readBook(_loadFromAssets('assets/book.epub')),
+   document: EpubDocument.openAsset('assets/book.epub'),
);
```

## 2.3.0

* Epub v3 support 
* Upgrade dependencies

## 2.2.1

* Upgrade dependencies

## 2.2.0

* Upgrade dependencies
* Minimum flutter version 2.2.0

## 2.1.0
### Changed
* Removed data property from `EpubController`, now `EpubReader.readBook` can receive futures
```diff
EpubController(
-  data: _loadFromAssets('assets/book.epub'),
+  document: EpubReader.readBook(_loadFromAssets('assets/book.epub'))
);
```

## 2.0.0

* Null-safety migration & Flutter v2 capability
* Upgraded dependencies
* Make `[epub]` package fork with name `[epubx]` and use it

## 1.0.0

* Rename `EpubReaderView` -> `EpubView`
* Rename `EpubReaderController` -> `EpubReaderController`
* Removed constructors `EpubReaderView.fromBytes` (pass data to controller), `EpubReaderView.builder` (builder available in default constructor)
* Documents load from controller by pass Future<Uint8List> or Uint8List
* Property `controller` now requires `EpubReaderController`
* Added properties:
  1. onDocumentLoaded(EpubBook document) - calls on document loaded
  2. onDocumentError(Exception error) - calls on loading document error
  3. Widget errorBuilder(Exception error) - show document loading error in EpubViexs
* Added MacOS support
* For web support see [flutter_html issue#300](https://github.com/Sub6Resources/flutter_html/issues/300)

## 0.8.0

* Replaced package `flutter_widgets` to `scrollable_positioned_list`
* Upgraded `flutter_html` dependency
* Set minimal flutter version to 1.17.0

## 0.7.0

* Expose chapter & items length into `EpubReaderTableOfContents` builder
* Added padding property in `EpubReaderTableOfContents`

## 0.6.0

* Removed `excludeHeaders`, `headerBuilder`, `startFrom` (use for replacement `epubCfi`)
* Added `onExternalLinkPressed(String href)` for open external links
* Added support for document hyperlinks
* Added model `Paragraph` contains dom element & associated chapter index
* Changed attribute paragraphs for `ChaptersBuilder` from `List<dom.Element> paragraphs` to `List<Paragraph> paragraphs`
* Added widgets: `EpubReaderTableOfContents`, `EpubActualChapter`
* In controller added `currentValueStream`, `tableOfContentsStream`, `gotoEpubCfi(cfiString)`
* Refactoring

## 0.5.0

* Added support for tables and images

## 0.4.2

* Fixed opening some epub files (w/o id paragraph in *.ncx)

## 0.4.1

* Fixed epub-reader controller attaching

## 0.4.0

* Added more versatility of epub parser
* Added table of contents
* Parser and loader optimization - move the procedure to the background

## 0.3.1

* Fixed epub-cfi parsing

## 0.3.0

* Added controller to EpubReaderView widget

## 0.2.0

* Added epub cfi support

## 0.1.0

* Initial release
