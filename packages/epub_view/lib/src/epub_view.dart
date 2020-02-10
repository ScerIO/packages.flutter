import 'dart:async';

import 'package:epub/epub.dart';
import 'package:epub_view/src/epub_cfi/parser.dart';
import 'package:epub_view/src/epub_cfi/generator.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
export 'package:epub/epub.dart';

const _defaultTextStyle = TextStyle(
  height: 1.25,
  fontSize: 16,
);

typedef ChaptersBuilder = Widget Function(
  BuildContext context,
  List<EpubChapter> chapters,
  int index,
);

class EpubReaderView extends StatefulWidget {
  const EpubReaderView({
    @required this.book,
    this.epubCfi,
    this.headerBuilder,
    this.dividerBuilder,
    this.onChange,
    this.startFrom,
    this.chapterPadding = const EdgeInsets.all(8),
    this.paragraphPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.textStyle = _defaultTextStyle,
    Key key,
  })  : itemBuilder = null,
        super(key: key);

  const EpubReaderView.builder({
    @required this.book,
    @required this.itemBuilder,
    this.epubCfi,
    this.headerBuilder,
    this.onChange,
    this.startFrom,
    this.chapterPadding = const EdgeInsets.all(8),
    this.paragraphPadding = const EdgeInsets.symmetric(horizontal: 8),
    Key key,
  })  : dividerBuilder = null,
        textStyle = null,
        super(key: key);

  final EpubBook book;
  final String epubCfi;
  final Widget Function(EpubChapterViewValue value) headerBuilder;
  final Widget Function(EpubChapter value) dividerBuilder;
  final void Function(EpubChapterViewValue value) onChange;
  final EpubReaderLastPosition startFrom;
  final EdgeInsetsGeometry chapterPadding;
  final EdgeInsetsGeometry paragraphPadding;
  final ChaptersBuilder itemBuilder;
  final TextStyle textStyle;

  @override
  _EpubReaderViewState createState() => _EpubReaderViewState();
}

class _EpubReaderViewState extends State<EpubReaderView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionListener =
      ItemPositionsListener.create();
  List<EpubChapter> _chapters;
  List<String> _paragraphs;
  EpubCfiReader _epubCfiReader;
  final List<int> _chapterParargraphCounts = [];
  final StreamController<EpubChapterViewValue> _actualItem = StreamController();

  @override
  void initState() {
    _chapters = widget.book.Chapters.fold<List<EpubChapter>>(
      [],
      (acc, next) => acc..addAll(next.SubChapters),
    );
    _paragraphs = _chapters.fold<List<String>>(
      [],
      (acc, next) {
        final pList = _paragraphBreak(next.HtmlContent);
        _chapterParargraphCounts.add(pList.length);
        return acc..addAll(pList);
      },
    );
    _epubCfiReader = EpubCfiReader(
      widget.epubCfi,
      chapters: _chapters,
      chapterParargraphCounts: _chapterParargraphCounts,
    );
    _itemPositionListener.itemPositions.addListener(_changeListener);
    super.initState();
  }

  @override
  void dispose() {
    _itemPositionListener.itemPositions.removeListener(_changeListener);
    _actualItem.close();
    super.dispose();
  }

  void _changeListener() {
    final position = _itemPositionListener.itemPositions.value.first;
    final chapterIndex = _getChapterIndexBy(position: position);
    final value = EpubChapterViewValue(
      chapter: _chapters[chapterIndex],
      chapterNumber: chapterIndex + 1,
      paragraphNumber: _getParagraphIndexBy(position: position) + 1,
      position: position,
      paragraph: _paragraphs[position.index],
    );
    _actualItem.sink.add(value);
    widget.onChange?.call(value);
  }

  int _getChapterIndexBy({ItemPosition position}) {
    int index = 0;
    int sum = 0;
    _chapterParargraphCounts.forEach((count) {
      sum += count;
      if (position.index >= sum) {
        index++;
      }
    });
    return index;
  }

  int _getParagraphIndexBy({ItemPosition position}) {
    int sum = 0;
    int index = position.index;
    _chapterParargraphCounts.forEach((count) {
      if (position.index >= sum) {
        index -= sum;
        sum += count;
      }
    });
    return index;
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildItem(BuildContext context, int index) =>
        widget.itemBuilder?.call(context, _chapters, index) ??
        _defaultItemBuilder(index);

    Widget content = ScrollablePositionedList.builder(
      initialScrollIndex: _epubCfiReader.lastPosition?._itemIndex ??
          widget.startFrom?._itemIndex ??
          0,
      initialAlignment: _epubCfiReader.lastPosition?.leadingEdge ??
          widget.startFrom?.leadingEdge ??
          0,
      itemCount: _paragraphs.length,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionListener,
      itemBuilder: _buildItem,
    );

    if (widget.headerBuilder != null) {
      content = Column(
        children: <Widget>[
          StreamBuilder<EpubChapterViewValue>(
            stream: _actualItem.stream,
            builder: (_, snapshot) => widget.headerBuilder(snapshot.data),
          ),
          Expanded(child: content)
        ],
      );
    }

    return content;
  }

  Widget _defaultItemBuilder(index) {
    // Widget _buildDivider(EpubChapter chapter) =>
    //     widget.dividerBuilder?.call(chapter) ??
    //     Container(
    //       height: 56,
    //       width: double.infinity,
    //       padding: EdgeInsets.all(16),
    //       decoration: BoxDecoration(
    //         color: Color(0x24000000),
    //       ),
    //       alignment: Alignment.centerLeft,
    //       child: Text(
    //         'Chapter ${chapter.Title}',
    //         style: TextStyle(
    //           fontSize: 18,
    //           fontWeight: FontWeight.w500,
    //         ),
    //       ),
    //     );

    // final chapter = _chapters[index];
    // final nextChapter =
    //     index + 1 <= _chapters.length - 1 ? _chapters[index + 1] : null;
    // final parsed = chapter.HtmlContent.replaceAll('<title/>', '');

    return Column(
      children: <Widget>[
        Html(
          padding: widget.paragraphPadding,
          data: _paragraphs[index],
          defaultTextStyle: widget.textStyle,
        ),
        // if (nextChapter != null) _buildDivider(nextChapter),
      ],
    );
  }

  List<String> _paragraphBreak(String htmlContent) {
    final regExp = RegExp(
      r'<p.*?>.+?</p>',
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    );
    final matches = regExp.allMatches(htmlContent);

    return matches.map((match) => match.group(0)).toList();
  }
}

class EpubChapterViewValue {
  const EpubChapterViewValue({
    @required this.chapter,
    @required this.chapterNumber,
    @required this.paragraphNumber,
    @required this.position,
    @required this.paragraph,
  });

  final EpubChapter chapter;
  final int chapterNumber;
  final int paragraphNumber;
  final ItemPosition position;
  final String paragraph;

  /// Chapter view in percents
  double get progress => _calcProgress(
        position.itemLeadingEdge,
        position.itemTrailingEdge,
      );

  EpubReaderLastPosition get asLastPosition => EpubReaderLastPosition.detail(
        position.index,
        position.itemLeadingEdge,
        position.itemTrailingEdge,
      );
}

class EpubReaderLastPosition {
  EpubReaderLastPosition(
    int chapterNumber,
  )   : _itemIndex = chapterNumber - 1,
        leadingEdge = null,
        trailingEdge = null;

  EpubReaderLastPosition.detail(
    int itemIndex,
    this.leadingEdge,
    this.trailingEdge,
  ) : _itemIndex = itemIndex;

  factory EpubReaderLastPosition.fromString(String value) {
    final values = value.split(':');
    return EpubReaderLastPosition.detail(
      int.parse(values[0]),
      double.parse(values[1]),
      double.parse(values[2]),
    );
  }

  int get chapterNumber => _itemIndex + 1;
  int _itemIndex;
  final double leadingEdge, trailingEdge;

  double get progress => _calcProgress(
        leadingEdge,
        trailingEdge,
      );

  @override
  String toString() => '$chapterNumber:$leadingEdge:$trailingEdge';
}

class EpubCfiReader {
  EpubCfiReader(
    this.cfiInput, {
    @required this.chapters,
    @required this.chapterParargraphCounts,
  });

  final String cfiInput;
  final List<EpubChapter> chapters;
  final List<int> chapterParargraphCounts;
  CfiFragment _cfiFragment;
  EpubReaderLastPosition _lastPosition;

  EpubReaderLastPosition get lastPosition {
    if (_lastPosition == null) {
      _cfiFragment = parseCfi(cfiInput);
      _lastPosition = convertToLastPosition(_cfiFragment);
    }
    return _lastPosition;
  }

  CfiFragment parseCfi(String cfiInput) =>
      EpubCfiParser().parse(cfiInput, 'fragment');

  EpubReaderLastPosition convertToLastPosition(CfiFragment cfiFragment) {
    if (cfiFragment == null ||
        cfiFragment.path?.localPath?.steps == null ||
        cfiFragment.path.localPath.steps.isEmpty) {
      return null;
    }

    final int chapterNumber =
        _getChapterNumberBy(cfiStep: cfiFragment.path.localPath.steps.first);
    final int paragraphNumber =
        _getParagraphNumberBy(cfiStep: cfiFragment.path.localPath.steps.last);
    final int chapterParagraphNumber =
        _getChapterParagraphNumberBy(chapterNumber: chapterNumber);

    return EpubReaderLastPosition(chapterParagraphNumber + paragraphNumber);
  }

  static String generateCfi({
    @required EpubBook book,
    @required EpubChapter chapter,
    String paragraph,
  }) {
    final document = _chapterDocument(chapter);
    final pElements = document.getElementsByTagName('p');
    dom.Element currNode = pElements
        .firstWhere((elm) => elm.outerHtml == paragraph, orElse: () => null);
    if (currNode == null) {
      currNode = pElements[0];
    }

    final generator = EpubCfiGenerator();
    final packageDocumentCFIComponent =
        generator.generatePackageDocumentCFIComponent(
            chapter.Anchor, book.Schema.Package);
    final contentDocumentCFIComponent =
        generator.generateElementCFIComponent(currNode);

    return generator.generateCompleteCFI(
        packageDocumentCFIComponent, contentDocumentCFIComponent);
  }

  static dom.Document _chapterDocument(EpubChapter chapter) {
    if (chapter == null) {
      return null;
    }

    final regExp = RegExp(
      r'<body.*?>.+?</body>',
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    );
    final matches = regExp.firstMatch(chapter.HtmlContent);

    return parse(matches.group(0));
  }

  int _getChapterNumberBy({CfiStep cfiStep}) {
    if (cfiStep == null) {
      return 1;
    }

    int index = 0;
    chapters.firstWhere((chapter) {
      if (chapter.Anchor == cfiStep.idAssertion) {
        return true;
      }
      index++;
      return false;
    });

    return index >= chapters.length ? 1 : index + 1;
  }

  int _getParagraphNumberBy({CfiStep cfiStep}) {
    if (cfiStep == null) {
      return 1;
    }

    return ((cfiStep.stepLength / 2) - 1).toInt();
  }

  int _getChapterParagraphNumberBy({int chapterNumber}) {
    if ((chapterNumber ?? 1) == 1) {
      return 0;
    }

    int number = 1;
    int result = 0;
    chapterParargraphCounts.forEach((count) {
      if (chapterNumber > number) {
        result += count;
      }
      number++;
    });

    return result;
  }
}

double _calcProgress(double leadingEdge, double trailingEdge) {
  final itemLeadingEdgeAbsolute = leadingEdge.abs();
  final fullHeight = itemLeadingEdgeAbsolute + trailingEdge;
  final heightPercent = fullHeight / 100;
  return itemLeadingEdgeAbsolute / heightPercent;
}
