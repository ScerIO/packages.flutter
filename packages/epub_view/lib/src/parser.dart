import 'package:epub/epub.dart';
import 'package:epub_view/src/epub_view.dart';
import 'package:html/dom.dart' as dom;

List<EpubChapter> parseChapters(EpubBook epubBook) =>
    epubBook.Chapters.fold<List<EpubChapter>>(
      [],
      (acc, next) {
        acc.add(next);
        next.SubChapters.forEach(acc.add);
        return acc;
      },
    );

List<dynamic> parseParagraphs(List<EpubChapter> chapters, bool excludeHeaders) {
  String filename = '';
  final List<int> chapterIndexes = [];
  final paragraphs = chapters.fold<List<dom.Element>>(
    [],
    (acc, next) {
      List<dom.Element> elmList = [];
      if (filename != next.ContentFileName) {
        filename = next.ContentFileName;
        final document = EpubCfiReader().chapterDocument(next);
        elmList = EpubCfiReader().convertDocumentToElements(document);
        acc.addAll(elmList);
      }

      if (next.Anchor == null) {
        // last element from document index as chapter index
        chapterIndexes.add(acc.length - elmList.length);
      } else {
        final index = acc.indexWhere(
          (elm) => elm.outerHtml.contains(
            'id="${next.Anchor}"',
          ),
        );
        chapterIndexes.add(index);
        if (acc[index + 1].localName == 'span') {
          acc.removeAt(index + 1);
        }
        if (acc[index].localName == 'span' || excludeHeaders) {
          acc.removeAt(index);
        }
      }

      return acc;
    },
  );

  return [paragraphs, chapterIndexes];
}
