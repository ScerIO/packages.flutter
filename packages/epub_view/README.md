# flutter_epub

Flutter widget for view EPUB documents on all platforms. Based on [epub](https://pub.dev/packages/epub) package.

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

@override
Widget build(BuildContext context) => Scaffold(
  body: FutureBuilder<EpubBook>(
    future: _loadFromAssets('assets/book.epub').then(EpubReader.readBook),
    builder: (_, snapshot) {
      if (snapshot.hasData) {
        return EpubReaderView(
          book: snapshot.data,
          // Called when scrolled to another chapter
          headerBuilder: (value) => AppBar(
            title: Text(
              'Chapter ${value?.chapter?.Title ?? 'Loading...'}',
            ),
          ),
          // Start from special chapter
          startFrom: EpubReaderLastPosition(3),
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
EpubReaderView(
  ...,
  // At first add on change callback
  onChange: (value) {
    // next get last position for save
    final lastPositionString = value.asLastPosition.toString();
    // save last position string anywhere
  }
);

// next step usage last position string:
EpubReaderView(
  startFrom: EpubReaderLastPosition.fromString(lastPositionString),
);
```

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
