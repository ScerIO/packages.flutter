import 'package:epub_view/src/data/epub_parser.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

export 'package:epubx/epubx.dart' hide Image;

class EpubChapterViewValue {
  const EpubChapterViewValue({
    required this.chapter,
    required this.chapterNumber,
    required this.paragraphNumber,
    required this.position,
  });

  final EpubChapter? chapter;
  final int chapterNumber;
  final int paragraphNumber;
  final ItemPosition position;

  /// Chapter view in percents
  double get progress {
    final itemLeadingEdgeAbsolute = position.itemLeadingEdge.abs();
    final fullHeight = itemLeadingEdgeAbsolute + position.itemTrailingEdge;
    final heightPercent = fullHeight / 100;
    return itemLeadingEdgeAbsolute / heightPercent;
  }
}
