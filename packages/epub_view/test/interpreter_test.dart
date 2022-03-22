import 'dart:io';
import 'dart:typed_data';

import 'package:epub_view/src/data/epub_cfi/epub_cfi.dart';
import 'package:epub_view/src/data/epub_cfi_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';

Future<Uint8List> _loadTestBook() async {
  // final url = Directory.current.path.replaceFirst(
  //     RegExp(r'/epub_view.*'), '/epub_view/test/assets/book.epub');
  final file = File('test/assets/book.epub');
  return file.readAsBytes();
}

void main() {
  late EpubBook _book;
  late CfiFragment _cfiFragment;

  setUp(() async {
    _book = await _loadTestBook().then(EpubReader.readBook);
    _cfiFragment =
        EpubCfiParser().parse('epubcfi(/6/2[id3]!/4/2/2[id3]/6)', 'fragment');
  });

  test('searchLocalPathForHref failed', () async {
    Element? result;
    try {
      final document =
          EpubCfiReader().chapterDocument(_book.Chapters![0].SubChapters![2]);
      result = EpubCfiInterpreter().searchLocalPathForHref(
        document!.documentElement,
        _cfiFragment.path!.localPath!,
      );
    } catch (e) {
      expect(
        e.toString(),
        FlutterError('id3: id4 Id assertion failed').toString(),
      );
    }

    expect(result, null);
  });

  test('searchLocalPathForHref success', () async {
    final document =
        EpubCfiReader().chapterDocument(_book.Chapters![0].SubChapters![1]);
    final result = EpubCfiInterpreter().searchLocalPathForHref(
      document!.documentElement,
      _cfiFragment.path!.localPath!,
    )!;

    expect(result.toString(), Element.tag('p').toString());
    expect(result.innerHtml,
        '<em>niedziela 14 maja 1933 roku. Godzina dziesiąta rano</em>');
  });
}
