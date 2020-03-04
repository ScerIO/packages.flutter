import 'dart:async';

import 'package:epub/epub.dart';
import 'package:epub_view/src/epub_cfi/interpreter.dart';
import 'package:epub_view/src/epub_cfi/parser.dart';
import 'package:epub_view/src/epub_cfi/generator.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
export 'package:epub/epub.dart';

const MIN_TRAILING_EDGE = 0.55;
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

class EpubReaderView extends StatefulWidget {
  const EpubReaderView({
    @required this.book,
    this.controller,
    this.epubCfi,
    this.excludeHeaders = false,
    this.loader,
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
    this.controller,
    this.epubCfi,
    this.excludeHeaders = false,
    this.loader,
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
  final EpubReaderController controller;
  final String epubCfi;
  final bool excludeHeaders;
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
  ItemScrollController _itemScrollController;
  ItemPositionsListener _itemPositionListener;
  List<EpubChapter> _chapters = [];
  List<dom.Element> _paragraphs = [];
  EpubCfiReader _epubCfiReader;
  EpubChapterViewValue _currentValue;
  bool _inited = false;

  final List<int> _chapterIndexes = [];
  final StreamController<EpubChapterViewValue> _actualItem = StreamController();

  @override
  void initState() {
    _itemScrollController = ItemScrollController();
    _itemPositionListener = ItemPositionsListener.create();
    widget.controller?._attach(this);
    super.initState();
  }

  @override
  void dispose() {
    _itemPositionListener.itemPositions.removeListener(_changeListener);
    _actualItem.close();
    widget.controller?._detach();
    super.dispose();
  }

  Future<bool> _init() async {
    if (_inited) {
      return true;
    }

    if (widget.book != null) {
      _chapters = _parseChapters(widget.book);
      _paragraphs = _parseParagraphs(_chapters);
    }
    _epubCfiReader = EpubCfiReader.parser(
      cfiInput: widget.epubCfi,
      chapters: _chapters,
      paragraphs: _paragraphs,
    );
    _itemPositionListener.itemPositions.addListener(_changeListener);
    _inited = true;

    return true;
  }

  void _changeListener() {
    if (_paragraphs.isEmpty ||
        _itemPositionListener.itemPositions.value.isEmpty) {
      return;
    }
    final position = _itemPositionListener.itemPositions.value.first;
    final chapterIndex = _getChapterIndexBy(positionIndex: position.index);
    _currentValue = EpubChapterViewValue(
      chapter: chapterIndex >= 0 ? _chapters[chapterIndex] : null,
      chapterNumber: chapterIndex + 1,
      paragraphNumber: _getParagraphIndexBy(
              positionIndex: position.index,
              trailingEdge: position.itemTrailingEdge) +
          1,
      position: position,
    );
    _actualItem.sink.add(_currentValue);
    widget.onChange?.call(_currentValue);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: _init(),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            return _buildMain();
          }
          return widget.loader ??
              Center(
                child: CircularProgressIndicator(),
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

  List<EpubChapter> _parseChapters(EpubBook book) =>
      book.Chapters.fold<List<EpubChapter>>(
        [],
        (acc, next) {
          if ((next.Anchor ?? '').isNotEmpty) {
            acc.add(next);
          }
          for (final sub in next.SubChapters) {
            if ((sub.Anchor ?? '').isNotEmpty) {
              acc.add(sub);
            }
          }
          return acc;
        },
      );

  List<dom.Element> _parseParagraphs(List<EpubChapter> chapters) {
    String filename = '';
    final result = chapters.fold<List<dom.Element>>(
      [],
      (acc, next) {
        List<dom.Element> elmList = [];
        if (filename != next.ContentFileName) {
          filename = next.ContentFileName;
          final document = EpubCfiReader().chapterDocument(next);
          elmList = EpubCfiReader().convertDocumentToElements(document);
          acc.addAll(elmList);
        }
        final index = acc
            .indexWhere((elm) => elm.outerHtml.contains('id="${next.Anchor}"'));
        _chapterIndexes.add(index);
        if (acc[index + 1].localName == 'span') {
          acc.removeAt(index + 1);
        }
        if (acc[index].localName == 'span' || widget.excludeHeaders) {
          acc.removeAt(index);
        }
        return acc;
      },
    );

    return result;
  }

  int _getChapterIndexBy({int positionIndex}) {
    final index = positionIndex >= _chapterIndexes.last
        ? _chapterIndexes.length
        : _chapterIndexes.indexWhere((chapterIndex) {
            if (positionIndex < chapterIndex) {
              return true;
            }
            return false;
          });

    return index - 1;
  }

  int _getParagraphIndexBy({@required int positionIndex, double trailingEdge}) {
    int posIndex = positionIndex;
    if (trailingEdge != null && trailingEdge < MIN_TRAILING_EDGE) {
      posIndex += 1;
    }

    final index = _getChapterIndexBy(positionIndex: posIndex);

    if (index == -1) {
      return posIndex;
    }

    return posIndex - _chapterIndexes[index];
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

  EpubChapterViewValue get currentValue => _epubReaderViewState?._currentValue;

  void jumpTo({@required int index, double alignment = 0}) =>
      _epubReaderViewState?._itemScrollController?.jumpTo(
        index: index,
        alignment: alignment,
      );

  Future<void> scrollTo(
          {@required int index,
          double alignment = 0,
          Duration duration = const Duration(milliseconds: 250),
          Curve curve = Curves.linear}) =>
      _epubReaderViewState?._itemScrollController?.scrollTo(
        index: index,
        duration: duration,
        alignment: alignment,
        curve: curve,
      );

  String generateEpubCfi() => _epubReaderViewState?._epubCfiReader?.generateCfi(
        book: _epubReaderViewState?.widget?.book,
        chapter: _epubReaderViewState?._currentValue?.chapter,
        paragraphIndex:
            (_epubReaderViewState?._currentValue?.paragraphNumber ?? 0) - 1,
      );

  List<EpubReaderChapter> tableOfContents() {
    if (_epubReaderViewState?.widget?.book == null) {
      return [];
    }
    int index = -1;
    return _epubReaderViewState.widget.book.Chapters
        .fold<List<EpubReaderChapter>>(
      [],
      (acc, next) {
        if ((next.Anchor ?? '').isNotEmpty) {
          index += 1;
          acc.add(EpubReaderChapter(next.Title, _getChapterStartIndex(index)));
        }
        for (final subChapter in next.SubChapters) {
          if ((subChapter.Anchor ?? '').isNotEmpty) {
            index += 1;
            acc.add(EpubReaderSubChapter(
                subChapter.Title, _getChapterStartIndex(index)));
          }
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
    assert(_epubReaderViewState == null);
    _epubReaderViewState = epubReaderViewState;
  }

  void _detach() {
    assert(_epubReaderViewState != null);
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
