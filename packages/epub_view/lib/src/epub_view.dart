import 'dart:async';
import 'dart:typed_data';

import 'package:epub/epub.dart' hide Image;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:rxdart/rxdart.dart';

import 'epub_cfi/generator.dart';
import 'epub_cfi/interpreter.dart';
import 'epub_cfi/parser.dart';

part 'epub_data.dart';
part 'epub_parser.dart';
part 'epub_controller.dart';
part 'epub_cfi_reader.dart';

const MIN_TRAILING_EDGE = 0.55;
const MIN_LEADING_EDGE = -0.05;

const _defaultTextStyle = TextStyle(
  height: 1.25,
  fontSize: 16,
);

typedef ChaptersBuilder = Widget Function(
  BuildContext context,
  List<EpubChapter> chapters,
  List<Paragraph> paragraphs,
  int index,
);

typedef ExternalLinkPressed = void Function(String href);

class EpubReaderView extends StatefulWidget {
  const EpubReaderView({
    @required this.book,
    this.controller,
    this.onExternalLinkPressed,
    this.epubCfi,
    this.loaderSwitchDuration,
    this.loader,
    this.dividerBuilder,
    this.onChange,
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
    this.onExternalLinkPressed,
    this.epubCfi,
    this.loaderSwitchDuration,
    this.loader,
    this.dividerBuilder,
    this.onChange,
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
    this.onExternalLinkPressed,
    this.epubCfi,
    this.loaderSwitchDuration,
    this.loader,
    this.onChange,
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
  final ExternalLinkPressed onExternalLinkPressed;
  final Duration loaderSwitchDuration;
  final Widget loader;
  final Widget Function(EpubChapter value) dividerBuilder;
  final void Function(EpubChapterViewValue value) onChange;
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
  List<Paragraph> _paragraphs = [];
  EpubCfiReader _epubCfiReader;
  EpubChapterViewValue _currentValue;
  bool _initialized = false;

  List<int> _chapterIndexes = [];
  final BehaviorSubject<EpubChapterViewValue> _actualChapter =
      BehaviorSubject();
  final BehaviorSubject<bool> _bookLoaded = BehaviorSubject();

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
    _actualChapter.close();
    _bookLoaded.close();
    widget.controller?._detach();
    super.dispose();
  }

  static Future<ParseResult> parseBook(Uint8List data) async {
    final epubBook = await EpubReader.readBook(data);
    final chapters = parseChapters(epubBook);
    final result = parseParagraphs(chapters, epubBook.Content);

    return ParseResult(epubBook, chapters, result);
  }

  Future<bool> _init() async {
    if (_initialized) {
      return true;
    }
    if (_book != null) {
      _chapters = parseChapters(_book);
      final parseParagraphsResult = parseParagraphs(_chapters, _book.Content);
      _paragraphs = parseParagraphsResult.flatParagraphs;
      _chapterIndexes.addAll(parseParagraphsResult.chapterIndexes);
    } else if (widget.bookData != null) {
      final result = await compute(parseBook, widget.bookData);
      _book = result.epubBook;
      _chapters = result.chapters;
      _paragraphs = result.parseResult.flatParagraphs;
      _chapterIndexes = result.parseResult.chapterIndexes;
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
    _actualChapter.sink.add(_currentValue);
    widget.onChange?.call(_currentValue);
  }

  void _gotoEpubCfi(
    String epubCfi, {
    double alignment = 0,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) {
    _epubCfiReader?.epubCfi = epubCfi;
    final index = _epubCfiReader?.paragraphIndexByCfiFragment;

    if (index == null) {
      return null;
    }

    _itemScrollController?.scrollTo(
      index: index,
      duration: duration,
      alignment: alignment,
      curve: curve,
    );
  }

  void _onLinkPressed(String href, void Function(String href) openExternal) {
    if (href.contains('://')) {
      openExternal?.call(href);
      return;
    }

    // Chapter01.xhtml#ph1_1 -> [ph1_1, Chapter01.xhtml] || [ph1_1]
    String hrefIdRef;
    String hrefFileName;

    if (href.contains('#')) {
      final dividedHref = href.split('#');
      if (dividedHref.length == 1) {
        hrefIdRef = href;
      } else {
        hrefFileName = dividedHref[0];
        hrefIdRef = dividedHref[1];
      }
    } else {
      hrefFileName = href;
    }

    if (hrefIdRef == null) {
      final chapter = _chapterByFileName(hrefFileName);
      if (chapter != null) {
        final cfi = _epubCfiReader?.generateCfiChapter(
          book: _book,
          chapter: chapter,
          additional: ['/4/2'],
        );

        if (widget.controller == null) {
          throw Exception();
        }

        _gotoEpubCfi(cfi);
      }
      return;
    } else {
      final paragraph = _paragraphByIdRef(hrefIdRef);
      final chapter =
          paragraph != null ? _chapters[paragraph.chapterIndex] : null;

      if (chapter != null && paragraph != null) {
        final paragraphIndex =
            _epubCfiReader?._getParagraphIndexByElement(paragraph.element);
        final cfi = _epubCfiReader?.generateCfi(
          book: _book,
          chapter: chapter,
          paragraphIndex: paragraphIndex,
        );

        _gotoEpubCfi(cfi);
      }

      return;
    }
  }

  Paragraph _paragraphByIdRef(String idRef) =>
      _paragraphs?.firstWhere((paragraph) {
        if (paragraph.element.id == idRef) {
          return true;
        }

        return paragraph.element.children.isNotEmpty &&
            paragraph.element.children[0].id == idRef;
      }, orElse: () => null);

  EpubChapter _chapterByFileName(String fileName) =>
      _chapters?.firstWhere((chapter) {
        if (fileName != null) {
          if (chapter.ContentFileName.contains(fileName)) {
            return true;
          } else {
            return false;
          }
        }
        return false;
      }, orElse: () => null);

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

  Widget _defaultItemBuilder(int index) {
    if (_paragraphs.isEmpty) {
      return Container();
    }

    final chapterIndex = _getChapterIndexBy(positionIndex: index);

    return Column(
      children: <Widget>[
        if (chapterIndex >= 0 &&
            _getParagraphIndexBy(positionIndex: index) == 0)
          _buildDivider(_chapters[chapterIndex]),
        Html(
          data: _paragraphs[index].element.outerHtml,
          onLinkTap: (href) =>
              _onLinkPressed(href, widget.onExternalLinkPressed),
          style: {
            'html': Style(
              padding: widget.paragraphPadding,
            ).merge(Style.fromTextStyle(widget.textStyle)),
          },
          customRender: {
            'img': (context, child, attributes, node) {
              final url = attributes['src'].replaceAll('../', '');
              return Image(
                image: MemoryImage(
                  Uint8List.fromList(_book.Content.Images[url].Content),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildMain() {
    Widget _buildItem(BuildContext context, int index) =>
        widget.itemBuilder?.call(context, _chapters, _paragraphs, index) ??
        _defaultItemBuilder(index);

    return ScrollablePositionedList.builder(
      initialScrollIndex: _epubCfiReader.paragraphIndexByCfiFragment ?? 0,
      itemCount: _paragraphs.length,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionListener,
      itemBuilder: _buildItem,
    );
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
}
