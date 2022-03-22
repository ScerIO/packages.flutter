# epub_view

Pure flutter widget (non native) for view EPUB documents on all platforms. Based on [epub](https://pub.dev/packages/epub) package. Render with flutter widgets (not native view) on any platforms: **Web**, **MacOs**, **Windows** **Linux**, **Android** and **iOS**

## Showcase

<img width="50%" src="https://raw.githubusercontent.com/rbcprolabs/packages.flutter/master/packages/epub_view/example/media/example.gif?raw=true" />

## Getting Started
In your flutter project add the dependency:
```shell
flutter pub add epub_view
```

## Usage example:
```dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_epub/flutter_epub.dart';

late EpubController _epubController;

@override
void initState() {
  super.initState();
  _epubController = EpubController(
    // Load document
    document: EpubDocument.openAsset('assets/book.epub'),
    // Set start point
    epubCfi: 'epubcfi(/6/6[chapter-2]!/4/2/1612)',
  );
}

@override
Widget build(BuildContext context) => Scaffold(
  appBar: AppBar(
    // Show actual chapter name
    title: EpubViewActualChapter(
      controller: _epubController,
      builder: (chapterValue) => Text(
        'Chapter: ' + (chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? ''),
        textAlign: TextAlign.start,
      )
    ),
  ),
  // Show table of contents
  drawer: Drawer(
    child: EpubViewTableOfContents(
      controller: _epubController,
    ),
  ),
  // Show epub document
  body: EpubView(
    controller: _epubController,
  ),
);
```

### How start from last view position?
This method allows you to keep the exact reading position even inside the chapter:
```dart
_epubController = EpubController(
  // initialize with epub cfi string for open book from last position
  epubCfi: 'epubcfi(/6/6[chapter-2]!/4/2/1612)',
);

// Attach controller
EpubView(
  controller: _epubController,
);

// Get epub cfi string
// for example output - epubcfi(/6/6[chapter-2]!/4/2/1612)
final cfi = _epubController.generateEpubCfi();

// or usage controller for navigate
_epubController.gotoEpubCfi('epubcfi(/6/6[chapter-2]!/4/2/1612)');
```

## Api

### Open document

**Local document open:**
```dart
EpubDocument.openAsset('assets/sample.pdf')

EpubDocument.openData(FutureOr<Uint8List> data)

// Not supports on Web
EpubDocument.openFile('path/to/file/on/device')
```
**Network document open:**

Install [[network_file]](https://pub.dev/packages/internet_file) package (supports all platforms):
```shell
flutter pub add internet_file
```

And use it
```dart
import 'package:internet_file/internet_file.dart';

// The cors policy is required on the server. 
// You can raise your cors proxy.
EpubDocument.openData(InternetFile.get('https://link.to/book.epub'))
```

### Control document
```dart
// Get epub cfi string of actual view insets
// for example output - epubcfi(/6/6[chapter-2]!/4/2/1612)
final cfi = _epubController.generateEpubCfi();

// Navigate to paragraph in document
_epubController.gotoEpubCfi('epubcfi(/6/6[chapter-2]!/4/2/1612)');
```

### Document callbacks
```dart
EpubView(
  controller: epubController,
  
  onExternalLinkPressed: (href) {},

  onDocumentLoaded: (document) {},
  onChapterChanged: (chapter) {},
  onDocumentError: (error) {},
);
```
