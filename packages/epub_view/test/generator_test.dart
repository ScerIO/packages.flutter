import 'dart:io';
import 'dart:typed_data';

import 'package:epub/epub.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:epub_view/src/epub_cfi/generator.dart';
import 'package:html/dom.dart';

Future<Uint8List> _loadTestBook() async {
  final url = Directory.current.path.replaceFirst(
      RegExp(r'/epub_view.*'), '/epub_view/test/assets/book.epub');
  final file = File(url);
  return file.readAsBytes();
}

void main() {
  EpubBook _book;

  setUp(() async {
    _book = await _loadTestBook().then(EpubReader.readBook);
  });

  test('generatePackageDocumentCFIComponent packageDocument failed', () async {
    String result;
    try {
      result =
          EpubCfiGenerator().generatePackageDocumentCFIComponent('idRef', null);
    } catch (e) {
      expect(
        e.toString(),
        FlutterError('A package document must be supplied to generate a CFI')
            .toString(),
      );
    }

    expect(result, null);
  });

  test('generatePackageDocumentCFIComponent idRef failed', () async {
    String result;
    try {
      result = EpubCfiGenerator()
          .generatePackageDocumentCFIComponent('idRef', _book.Schema.Package);
    } catch (e) {
      expect(
        e.toString(),
        FlutterError(
                // ignore: lines_longer_than_80_chars
                'The idref of the content document could not be found in the spine')
            .toString(),
      );
    }

    expect(result, null);
  });

  test('generatePackageDocumentCFIComponent success', () async {
    String result;
    result = EpubCfiGenerator()
        .generatePackageDocumentCFIComponent('id4', _book.Schema.Package);

    expect(result, '/6/26[id4]!');
  });

  test('generateElementCFIComponent failed - startElement is null', () async {
    String result;
    try {
      result = EpubCfiGenerator().generateElementCFIComponent(null);
    } catch (e) {
      expect(
        e.toString(),
        FlutterError('null: CFI target element is null').toString(),
      );
    }

    expect(result, null);
  });

  test('generateElementCFIComponent failed - startElement has wrong type',
      () async {
    String result;
    try {
      result =
          EpubCfiGenerator().generateElementCFIComponent(Comment('comment'));
    } catch (e) {
      expect(
        e.toString(),
        FlutterError(
                '<!-- comment -->: CFI target element is not an HTML element')
            .toString(),
      );
    }

    expect(result, null);
  });

  test('generateElementCFIComponent success', () async {
    String result;
    final document = EpubCfiReader().chapterDocument(_book.Chapters[0]);
    final node = document.getElementsByTagName('p')[3];

    result = EpubCfiGenerator().generateElementCFIComponent(node);

    expect(result, '/4/2[id1]/4/2/4');
  });

  test('generateCompleteCFI success', () async {
    String result;
    final document =
        EpubCfiReader().chapterDocument(_book.Chapters[0].SubChapters[1]);
    final node = document.getElementsByTagName('p')[3];

    final packageDocumentCFIComponent = EpubCfiGenerator()
        .generatePackageDocumentCFIComponent('id3', _book.Schema.Package);
    final contentDocumentCFIComponent =
        EpubCfiGenerator().generateElementCFIComponent(node);

    result = EpubCfiGenerator().generateCompleteCFI(
        packageDocumentCFIComponent, contentDocumentCFIComponent);

    expect(result, 'epubcfi(/6/2[id3]!/4/2/2[id3]/8)');
  });
}
