import 'dart:async';

import 'package:epub/epub.dart';
import 'package:epub_view/src/epub_cfi/interpreter.dart';
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
        final document = EpubCfiReader().chapterDocument(next);
        final pList =
            document.getElementsByTagName('p').map((elm) => elm.outerHtml);
        _chapterParargraphCounts.add(pList.length);
        return acc..addAll(pList);
      },
    );
    _epubCfiReader = EpubCfiReader.parser(
      cfiInput: widget.epubCfi,
      chapters: _chapters,
      paragraphs: _paragraphs,
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
    final chapterIndex = _getChapterIndexBy(positionIndex: position.index);
    final value = EpubChapterViewValue(
      chapter: _chapters[chapterIndex],
      chapterNumber: chapterIndex + 1,
      paragraphNumber: _getParagraphIndexBy(positionIndex: position.index) + 1,
      position: position,
    );
    _actualItem.sink.add(value);
    widget.onChange?.call(value);
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
    Widget _buildDivider(EpubChapter chapter) =>
        widget.dividerBuilder?.call(chapter) ??
        Container(
          height: 56,
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0x24000000),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            'Chapter ${chapter.Title}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        );

    final chapterIndex = _getChapterIndexBy(positionIndex: index);
    final nextChapter = chapterIndex + 1 <= _chapters.length - 1
        ? _chapters[chapterIndex + 1]
        : null;

    return Column(
      children: <Widget>[
        Html(
          padding: widget.paragraphPadding,
          data: _paragraphs[index],
          defaultTextStyle: widget.textStyle,
        ),
        if (nextChapter != null && _isLastParagraph(index, chapterIndex))
          _buildDivider(nextChapter),
      ],
    );
  }

  int _getChapterIndexBy({int positionIndex}) {
    int sum = 0;
    final index = _chapterParargraphCounts.indexWhere((count) {
      sum += count;
      if (positionIndex < sum) {
        return true;
      }
      return false;
    });
    return index == -1 ? 0 : index;
  }

  int _getParagraphIndexBy({int positionIndex}) {
    int parargraphsCount = 0;
    int sum = 0;
    _chapterParargraphCounts.forEach((count) {
      sum += count;
      if (positionIndex >= sum) {
        parargraphsCount = sum;
      }
    });
    return positionIndex - parargraphsCount;
  }

  bool _isLastParagraph(int positionIndex, int chapterIndex) =>
      _getParagraphIndexBy(positionIndex: positionIndex) ==
      _chapterParargraphCounts[chapterIndex] - 1;
}

class EpubChapterViewValue {
  const EpubChapterViewValue({
    @required this.chapter,
    @required this.chapterNumber,
    @required this.paragraphNumber,
    @required this.position,
  });

  final EpubChapter chapter;
  final int chapterNumber;
  final int paragraphNumber;
  final ItemPosition position;

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
    int paragraphNumber,
  )   : _itemIndex = paragraphNumber - 1,
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

  int _itemIndex;
  final double leadingEdge, trailingEdge;

  int get paragraphNumber => _itemIndex + 1;

  double get progress => _calcProgress(
        leadingEdge,
        trailingEdge,
      );

  @override
  String toString() => '$paragraphNumber:$leadingEdge:$trailingEdge';
}

class EpubCfiReader {
  EpubCfiReader()
      : cfiInput = null,
        chapters = [],
        paragraphs = [],
        chapterParargraphCounts = [];

  EpubCfiReader.parser({
    @required this.cfiInput,
    @required this.chapters,
    @required this.paragraphs,
    @required this.chapterParargraphCounts,
  });

  final String cfiInput;
  final List<EpubChapter> chapters;
  final List<String> paragraphs;
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
    final chapter = chapters[chapterNumber - 1];
    final document = chapterDocument(chapter);
    final element = EpubCfiInterpreter().searchLocalPathForHref(
      document.documentElement,
      cfiFragment.path.localPath,
    );
    final int paragraphNumber = _getParagraphNumberBy(element: element);

    return EpubReaderLastPosition(paragraphNumber);
  }

  String generateCfi({
    @required EpubBook book,
    @required EpubChapter chapter,
    @required int paragraphNumber,
  }) {
    final document = chapterDocument(chapter);
    final pElements = document.getElementsByTagName('p');
    final pIndex = paragraphNumber > 0 ? paragraphNumber - 1 : 0;
    final currNode = pElements[pIndex];

    final generator = EpubCfiGenerator();
    final packageDocumentCFIComponent =
        generator.generatePackageDocumentCFIComponent(
            chapter.Anchor, book.Schema.Package);
    final contentDocumentCFIComponent =
        generator.generateElementCFIComponent(currNode);

    return generator.generateCompleteCFI(
        packageDocumentCFIComponent, contentDocumentCFIComponent);
  }

  dom.Document chapterDocument(EpubChapter chapter) {
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

    final index =
        chapters.indexWhere((chapter) => chapter.Anchor == cfiStep.idAssertion);

    return index == -1 ? 1 : index + 1;
  }

  int _getParagraphNumberBy({dom.Element element}) {
    if (element == null) {
      return 1;
    }

    final index = paragraphs.indexOf(element.outerHtml);

    return index == -1 ? 1 : index + 1;
  }
}

double _calcProgress(double leadingEdge, double trailingEdge) {
  final itemLeadingEdgeAbsolute = leadingEdge.abs();
  final fullHeight = itemLeadingEdgeAbsolute + trailingEdge;
  final heightPercent = fullHeight / 100;
  return itemLeadingEdgeAbsolute / heightPercent;
}
