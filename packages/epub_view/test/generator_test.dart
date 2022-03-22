import 'dart:io';
import 'dart:typed_data';

import 'package:epub_view/src/data/epub_cfi/epub_cfi.dart';
import 'package:epub_view/src/data/epub_cfi_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';

Future<Uint8List> _loadTestBook() async {
  // final url = Directory.current.path
  //     .replaceFirst(RegExp(r'epub_view.*'), '');
  final file = File('test/assets/book.epub');
  return file.readAsBytes();
}

void main() {
  late EpubBook _book;

  setUp(() async {
    _book = await _loadTestBook().then(EpubReader.readBook);
  });

  test('generatePackageDocumentCFIComponent packageDocument failed', () async {
    String? result;
    try {
      result = EpubCfiGenerator().generatePackageDocumentCFIComponent(
          EpubChapter()..Anchor = 'idRef', null);
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
    String? result;
    try {
      result = EpubCfiGenerator().generatePackageDocumentCFIComponent(
          EpubChapter()..Anchor = 'idRef', _book.Schema!.Package!);
    } catch (e) {
      // Condition is commented
      // This error will not be caused, because there is a case
      // when the id is not in the spine list
      expect(
        e.toString(),
        FlutterError(
                // ignore: lines_longer_than_80_chars
                'The id ref of the content document could not be found in the spine')
            .toString(),
      );
    }

    expect(result, '/6/0[idRef]!');
  });

  test('generatePackageDocumentCFIComponent success', () async {
    final result = EpubCfiGenerator().generatePackageDocumentCFIComponent(
        EpubChapter()..Anchor = 'id4', _book.Schema!.Package!);

    expect(result, '/6/26[id4]!');
  });

  // test('generatePackageDocumentCFIComponent filename', () async {
  //   final result = EpubCfiGenerator().generatePackageDocumentCFIComponent(
  //       EpubChapter()..ContentFileName = 'html/Chapter01.xml', _book.Schema.Package);

  //   expect(result, '/6/26[Chapter01]!');
  // });

  test('generateElementCFIComponent failed - startElement is null', () async {
    String? result;
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
    String? result;
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
    final document = EpubCfiReader().chapterDocument(_book.Chapters![0])!;
    final node = document.getElementsByTagName('p')[3];

    final result = EpubCfiGenerator().generateElementCFIComponent(node);

    expect(result, '/4/2[id1]/4/2/4');
  });

  test('generateCompleteCFI success', () async {
    final document =
        EpubCfiReader().chapterDocument(_book.Chapters![0].SubChapters![1])!;
    final node = document.getElementsByTagName('p')[2];

    final packageDocumentCFIComponent = EpubCfiGenerator()
        .generatePackageDocumentCFIComponent(
            EpubChapter()..Anchor = 'id3', _book.Schema!.Package!);
    final contentDocumentCFIComponent =
        EpubCfiGenerator().generateElementCFIComponent(node);

    final result = EpubCfiGenerator().generateCompleteCFI(
        [packageDocumentCFIComponent, contentDocumentCFIComponent]);

    expect(result, 'epubcfi(/6/2[id3]!/4/2/2[id3]/6)');
  });
}
