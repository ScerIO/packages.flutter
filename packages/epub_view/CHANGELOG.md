## 0.7.0

* Expose chapter & items length into `EpubReaderTableOfContents` builder

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
