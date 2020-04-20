import 'dart:async';
import 'dart:typed_data';

import 'package:epub/epub.dart';
import 'package:epub_view/src/epub_cfi/interpreter.dart';
import 'package:epub_view/src/epub_cfi/parser.dart';
import 'package:epub_view/src/epub_cfi/generator.dart';
import 'package:epub_view/src/parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
export 'package:epub/epub.dart';

const MIN_TRAILING_EDGE = 0.55;
const MIN_LEADING_EDGE = -0.05;
const _defaultTextStyle = TextStyle(
  height: 1.25,
  fontSize: 16,
);

typedef ChaptersBuilder = Widget Function(
  BuildContext context,
  List<EpubChapter> chapters,
  List<dom.Element> paragraphs,
  int index,
);

class ParseParams {
  const ParseParams(this.bookData, this.excludeHeaders);

  final Uint8List bookData;
  final bool excludeHeaders;
}

class ParseResult {
  const ParseResult(
      this.epubBook, this.chapters, this.paragraphs, this.chapterIndexes);

  final EpubBook epubBook;
  final List<EpubChapter> chapters;
  final List<dom.Element> paragraphs;
  final List<int> chapterIndexes;
}

class EpubReaderView extends StatefulWidget {
  const EpubReaderView({
    @required this.book,
    this.controller,
    this.epubCfi,
    this.excludeHeaders = false,
    this.loaderSwitchDuration,
    this.loader,
    this.headerBuilder,
    this.dividerBuilder,
    this.onChange,
    this.startFrom,
    this.chapterPadding = const EdgeInsets.all(8),
    this.paragraphPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.textStyle = _defaultTextStyle,
    Key key,
  })  : bookData = null,
        itemBuilder = null,
        super(key: key);

  const EpubReaderView.fromBytes({
    @required this.bookData,
    this.controller,
    this.epubCfi,
    this.excludeHeaders = false,
    this.loaderSwitchDuration,
    this.loader,
    this.headerBuilder,
    this.dividerBuilder,
    this.onChange,
    this.startFrom,
    this.chapterPadding = const EdgeInsets.all(8),
    this.paragraphPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.textStyle = _defaultTextStyle,
    Key key,
  })  : book = null,
        itemBuilder = null,
        super(key: key);

  const EpubReaderView.builder({
    @required this.book,
    @required this.itemBuilder,
    this.controller,
    this.epubCfi,
    this.excludeHeaders = false,
    this.loaderSwitchDuration,
    this.loader,
    this.headerBuilder,
    this.onChange,
    this.startFrom,
    this.chapterPadding = const EdgeInsets.all(8),
    this.paragraphPadding = const EdgeInsets.symmetric(horizontal: 8),
    Key key,
  })  : bookData = null,
        dividerBuilder = null,
        textStyle = null,
        super(key: key);

  final EpubBook book;
  final Uint8List bookData;
  final EpubReaderController controller;
  final String epubCfi;
  final bool excludeHeaders;
  final Duration loaderSwitchDuration;
  final Widget loader;
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
  EpubBook _book;
  ItemScrollController _itemScrollController;
  ItemPositionsListener _itemPositionListener;
  List<EpubChapter> _chapters = [];
  List<dom.Element> _paragraphs = [];
  EpubCfiReader _epubCfiReader;
  EpubChapterViewValue _currentValue;
  bool _initialized = false;

  List<int> _chapterIndexes = [];
  final StreamController<EpubChapterViewValue> _actualItem = StreamController();
  final StreamController<bool> _bookLoaded = StreamController();

  @override
  void initState() {
    _book = widget.book;
    _itemScrollController = ItemScrollController();
    _itemPositionListener = ItemPositionsListener.create();
    widget.controller?._attach(this);
    super.initState();
  }

  @override
  void dispose() {
    _itemPositionListener.itemPositions.removeListener(_changeListener);
    _actualItem.close();
    _bookLoaded.close();
    widget.controller?._detach();
    super.dispose();
  }

  static Future<ParseResult> parseBook(ParseParams params) async {
    final epubBook = await EpubReader.readBook(params.bookData);
    final chapters = parseChapters(epubBook);
    final result = parseParagraphs(chapters, params.excludeHeaders);

    return ParseResult(epubBook, chapters, result[0] as List<dom.Element>,
        result[1] as List<int>);
  }

  Future<bool> _init() async {
    if (_initialized) {
      return true;
    }
    if (_book != null) {
      _chapters = parseChapters(_book);
      final parseParagraphsResult =
          parseParagraphs(_chapters, widget.excludeHeaders);

      _paragraphs = parseParagraphsResult[0];
      _chapterIndexes.addAll(parseParagraphsResult[1]);
    } else if (widget.bookData != null) {
      final result = await compute(
          parseBook, ParseParams(widget.bookData, widget.excludeHeaders));
      _book = result.epubBook;
      _chapters = result.chapters;
      _paragraphs = result.paragraphs;
      _chapterIndexes = result.chapterIndexes;
    }

    _epubCfiReader = EpubCfiReader.parser(
      cfiInput: widget.epubCfi,
      chapters: _chapters,
      paragraphs: _paragraphs,
    );
    _itemPositionListener.itemPositions.addListener(_changeListener);
    _initialized = true;
    _bookLoaded.sink.add(true);

    return true;
  }

  void _changeListener() {
    if (_paragraphs.isEmpty ||
        _itemPositionListener.itemPositions.value.isEmpty) {
      return;
    }
    final position = _itemPositionListener.itemPositions.value.first;
    final chapterIndex = _getChapterIndexBy(
      positionIndex: position.index,
      trailingEdge: position.itemTrailingEdge,
      leadingEdge: position.itemLeadingEdge,
    );
    final paragraphIndex = _getParagraphIndexBy(
      positionIndex: position.index,
      trailingEdge: position.itemTrailingEdge,
      leadingEdge: position.itemLeadingEdge,
    );
    _currentValue = EpubChapterViewValue(
      chapter: chapterIndex >= 0 ? _chapters[chapterIndex] : null,
      chapterNumber: chapterIndex + 1,
      paragraphNumber: paragraphIndex + 1,
      position: position,
    );
    _actualItem.sink.add(_currentValue);
    widget.onChange?.call(_currentValue);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: _init(),
        builder: (_, snapshot) {
          Widget result =
              widget.loader ?? Center(child: CircularProgressIndicator());
          if (snapshot.hasData) {
            result = _buildMain();
          }
          return AnimatedSwitcher(
            duration:
                widget.loaderSwitchDuration ?? Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) =>
                FadeTransition(child: child, opacity: animation),
            child: result,
          );
        },
      );

  Widget _buildMain() {
    Widget _buildItem(BuildContext context, int index) =>
        widget.itemBuilder?.call(context, _chapters, _paragraphs, index) ??
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
    if (_paragraphs.isEmpty) {
      return Container();
    }
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
            chapter.Title ?? '',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

    final chapterIndex = _getChapterIndexBy(positionIndex: index);

    return Column(
      children: <Widget>[
        if (chapterIndex >= 0 &&
            _getParagraphIndexBy(positionIndex: index) == 0)
          _buildDivider(_chapters[chapterIndex]),
        Html(
          padding: widget.paragraphPadding,
          data: _paragraphs[index].outerHtml,
          defaultTextStyle: widget.textStyle,
        ),
      ],
    );
  }

  int _getChapterIndexBy({
    @required int positionIndex,
    double trailingEdge,
    double leadingEdge,
  }) {
    final posIndex = _getAbsParagraphIndexBy(
      positionIndex: positionIndex,
      trailingEdge: trailingEdge,
      leadingEdge: leadingEdge,
    );
    final index = posIndex >= _chapterIndexes.last
        ? _chapterIndexes.length
        : _chapterIndexes.indexWhere((chapterIndex) {
            if (posIndex < chapterIndex) {
              return true;
            }
            return false;
          });

    return index - 1;
  }

  int _getParagraphIndexBy({
    @required int positionIndex,
    double trailingEdge,
    double leadingEdge,
  }) {
    final posIndex = _getAbsParagraphIndexBy(
      positionIndex: positionIndex,
      trailingEdge: trailingEdge,
      leadingEdge: leadingEdge,
    );

    final index = _getChapterIndexBy(positionIndex: posIndex);

    if (index == -1) {
      return posIndex;
    }

    return posIndex - _chapterIndexes[index];
  }

  int _getAbsParagraphIndexBy({
    @required int positionIndex,
    double trailingEdge,
    double leadingEdge,
  }) {
    int posIndex = positionIndex;
    if (trailingEdge != null &&
        leadingEdge != null &&
        trailingEdge < MIN_TRAILING_EDGE &&
        leadingEdge < MIN_LEADING_EDGE) {
      posIndex += 1;
    }

    return posIndex;
  }
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
        paragraphs = [];

  EpubCfiReader.parser({
    @required this.cfiInput,
    @required this.chapters,
    @required this.paragraphs,
  });

  final String cfiInput;
  final List<EpubChapter> chapters;
  final List<dom.Element> paragraphs;
  CfiFragment _cfiFragment;
  EpubReaderLastPosition _lastPosition;

  EpubReaderLastPosition get lastPosition {
    if (_lastPosition == null) {
      try {
        _cfiFragment = parseCfi(cfiInput);
        _lastPosition = convertToLastPosition(_cfiFragment);
      } catch (e) {
        _lastPosition = null;
      }
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
    @required int paragraphIndex,
  }) {
    if (book == null || chapter == null || paragraphIndex == null) {
      return null;
    }
    final document = chapterDocument(chapter);
    if (document == null) {
      return null;
    }

    final currentNode = paragraphs[paragraphIndex];

    final generator = EpubCfiGenerator();
    final packageDocumentCFIComponent =
        generator.generatePackageDocumentCFIComponent(
            chapter.Anchor, book.Schema.Package);
    final contentDocumentCFIComponent =
        generator.generateElementCFIComponent(currentNode);

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

  List<dom.Element> convertDocumentToElements(dom.Document document) => document
      .getElementsByTagName('body')
      .first
      .querySelectorAll('h2,h3,h4,h5,h6,p,span[id]')
        ..removeWhere((elm) => elm.text.isEmpty)
        ..removeWhere((elm) => elm.outerHtml.endsWith('>&nbsp;</p>'));

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

    final index =
        paragraphs.indexWhere((elm) => elm.outerHtml == element.outerHtml);

    return index == -1 ? 1 : index + 1;
  }
}

class EpubReaderController {
  _EpubReaderViewState _epubReaderViewState;
  List<EpubReaderChapter> _cacheTableOfContents;

  final StreamController<bool> _streamController =
      StreamController<bool>.broadcast();

  EpubChapterViewValue get currentValue => _epubReaderViewState?._currentValue;

  Stream<bool> get bookLoadedStream => _streamController.stream;

  bool get isBookLoaded => _epubReaderViewState?._initialized;

  void jumpTo({@required int index, double alignment = 0}) =>
      _epubReaderViewState?._itemScrollController?.jumpTo(
        index: index,
        alignment: alignment,
      );

  Future<void> scrollTo({
    @required int index,
    double alignment = 0,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) =>
      _epubReaderViewState?._itemScrollController?.scrollTo(
        index: index,
        duration: duration,
        alignment: alignment,
        curve: curve,
      );

  String generateEpubCfi() => _epubReaderViewState?._epubCfiReader?.generateCfi(
        book: _epubReaderViewState?._book,
        chapter: _epubReaderViewState?._currentValue?.chapter,
        paragraphIndex: _epubReaderViewState?._getAbsParagraphIndexBy(
          positionIndex:
              _epubReaderViewState?._currentValue?.position?.index ?? 0,
          trailingEdge:
              _epubReaderViewState?._currentValue?.position?.itemTrailingEdge,
          leadingEdge:
              _epubReaderViewState?._currentValue?.position?.itemLeadingEdge,
        ),
      );

  List<EpubReaderChapter> tableOfContents() {
    if (_cacheTableOfContents != null) {
      return _cacheTableOfContents;
    }

    if (_epubReaderViewState?._book == null) {
      return [];
    }

    int index = -1;

    return _cacheTableOfContents =
        _epubReaderViewState._book.Chapters.fold<List<EpubReaderChapter>>(
      [],
      (acc, next) {
        // if ((next.Anchor ?? '').isNotEmpty) {
        index += 1;
        acc.add(EpubReaderChapter(next.Title, _getChapterStartIndex(index)));
        // }
        for (final subChapter in next.SubChapters) {
          // if ((subChapter.Anchor ?? '').isNotEmpty) {
          index += 1;
          acc.add(EpubReaderSubChapter(
              subChapter.Title, _getChapterStartIndex(index)));
          // }
        }
        return acc;
      },
    );
  }

  int _getChapterStartIndex(int index) =>
      index < _epubReaderViewState._chapterIndexes.length
          ? _epubReaderViewState._chapterIndexes[index]
          : 0;

  void _attach(_EpubReaderViewState epubReaderViewState) {
    if (_epubReaderViewState != null) {
      return;
    }
    _epubReaderViewState = epubReaderViewState;
    _epubReaderViewState._bookLoaded.stream.listen((bool value) {
      _streamController.sink.add(value);
    });
  }

  void _detach() {
    _epubReaderViewState = null;
  }
}

class EpubReaderChapter {
  EpubReaderChapter(this.title, this.startIndex);

  final String title;
  final int startIndex;

  String get type => this is EpubReaderSubChapter ? 'subchapter' : 'chapter';

  @override
  String toString() => '$type: {title: $title, startIndex: $startIndex}';
}

class EpubReaderSubChapter extends EpubReaderChapter {
  EpubReaderSubChapter(String title, int startIndex) : super(title, startIndex);
}

class EpubReaderContentFile {
  EpubReaderContentFile(this.filename, this.elements);

  String filename;
  List<String> elements;
}

double _calcProgress(double leadingEdge, double trailingEdge) {
  final itemLeadingEdgeAbsolute = leadingEdge.abs();
  final fullHeight = itemLeadingEdgeAbsolute + trailingEdge;
  final heightPercent = fullHeight / 100;
  return itemLeadingEdgeAbsolute / heightPercent;
}
