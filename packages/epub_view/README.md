# epub_view

Flutter widget for view EPUB documents on all platforms. Based on [epub](https://pub.dev/packages/epub) package. Render with flutter widgets (not native view)

## Showcase

<img width="50%" src="https://raw.githubusercontent.com/rbcprolabs/packages.flutter/master/packages/epub_view/example/media/example.gif?raw=true" />

## Getting Started

In your flutter project add the dependency:

[![pub package](https://img.shields.io/pub/v/epub_view.svg)](https://pub.dartlang.org/packages/epub_view)

```yaml
dependencies:
  epub_view: any
```

## Usage example:
```dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_epub/flutter_epub.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> _loadFromAssets(String assetName) async {
  final bytes = await rootBundle.load(assetName);
  return bytes.buffer.asUint8List();
}

EpubReaderController _epubReaderController;
Future<Uint8List> _bookContent;

@override
void initState() {
  _epubReaderController = EpubReaderController();
  _bookContent = _loadFromAssets('assets/book.epub');
  super.initState();
}

@override
Widget build(BuildContext context) => Scaffold(
  appBar: AppBar(
    // Show actual chapter name
    title: EpubActualChapter(
      controller: _epubReaderController,
      builder: (chapterValue) => Text(
        'Chapter ${chapterValue.chapter.Title ?? ''}',
        textAlign: TextAlign.start,
      ),
    ),
  ),
  // Show table of contents
  drawer: Drawer(
    child: EpubReaderTableOfContents(
      controller: _epubReaderController,
    ),
  ),
  // Show epub document
  body: FutureBuilder<Uint8List>(
    future: _bookContent,
    builder: (_, snapshot) {
      if (snapshot.hasData) {
        return EpubReaderView.fromBytes(
          controller: _epubReaderController,
          bookData: snapshot.data,
        );
      }

      return Center(
        child: CircularProgressIndicator(),
      );
    },
  ),
);
```

## How start from last view position?
This method allows you to keep the exact reading position even inside the chapter:
```dart
// Attach controller
EpubReaderView(
  controller: _epubReaderController,
);

// Get epub cfi string
// for example output - epubcfi(/6/6[chapter-2]!/4/2/1612)
final cfi = _epubReaderController.generateEpubCfi();

// next step usage cfi string on next initialization:
EpubReaderView(
  controller: _epubReaderController,
  epubCfi: 'epubcfi(/6/6[chapter-2]!/4/2/1612)',
);

// or usage controller for navigate
_epubReaderController.gotoEpubCfi('epubcfi(/6/6[chapter-2]!/4/2/1612)');
```

