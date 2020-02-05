import 'dart:async';

import 'package:epub/epub.dart';
import 'package:epub_view/src/parser/epub_cfi.dart';
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
  List<int> _chapterParargraphCounts = [];
  EpubCfiReader _epubCfiReader;
  final StreamController<EpubChapterViewValue> _actualItem = StreamController();

  @override
  void initState() {
    _epubCfiReader = EpubCfiReader(widget.epubCfi);
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
    print(_chapterParargraphCounts);
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
      number: chapterIndex + 1,
      position: position,
      paragraphIndex: _getParagraphIndexBy(position: position),
      paragraphsCount: _chapterParargraphCounts[chapterIndex],
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

    // final chapter = _chapters[index];
    // final nextChapter =
    //     index + 1 <= _chapters.length - 1 ? _chapters[index + 1] : null;
    // final parsed = chapter.HtmlContent.replaceAll('<title/>', '');

    return Column(
      children: <Widget>[
        Html(
          // padding: widget.chapterPadding,
          data: _paragraphs[index],
          defaultTextStyle: widget.textStyle,
        ),
        // if (nextChapter != null) _buildDivider(nextChapter),
      ],
    );
  }

  List<Widget> _buildChaptersSliverList() {
    return _chapters.map((chapter) {
      final paragraphs = _paragraphBreak(chapter.HtmlContent);

      return SliverPadding(
        key: Key(chapter.hashCode.toString()),
        padding: widget.chapterPadding,
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (c, i) => _buildParagraph(paragraphs, i),
            childCount: paragraphs.length,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildParagraph(List<String> paragraphs, int index) => Html(
        key: Key('p_$index'),
        data: paragraphs[index],
        defaultTextStyle: widget.textStyle,
      );

  List<String> _paragraphBreak(String htmlContent) {
    final regExp = RegExp(
      r'<p class=".+?">.+?</p>',
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
    @required this.number,
    @required this.position,
    @required this.paragraphIndex,
    @required this.paragraphsCount,
  });

  final EpubChapter chapter;
  final int number;
  final ItemPosition position;
  final int paragraphIndex;
  final int paragraphsCount;

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
  EpubCfiReader(this._cfiInput);

  final String _cfiInput;
  CfiFragment _cfiFragment;
  EpubReaderLastPosition _lastPosition;

  EpubReaderLastPosition get lastPosition {
    if (_lastPosition == null) {
      _cfiFragment = parseCfi(_cfiInput);
      _lastPosition = convertToLastPosition(_cfiFragment);
    }
    return _lastPosition;
  }

  CfiFragment parseCfi(String cfiInput) {
    final parser = EpubCfiParser();
    return parser.parse(cfiInput, 'fragment');
  }

  EpubReaderLastPosition convertToLastPosition(CfiFragment cfiFragment) {
    if (cfiFragment == null) {
      return null;
    }
    final int chapter = cfiFragment.path?.localPath?.steps[0]?.stepLength;

    return EpubReaderLastPosition(chapter);
  }

  // TODO(Ramil): create epub-cfi generator
  String generateCfi(EpubReaderLastPosition lastPosition) => '';
}

double _calcProgress(double leadingEdge, double trailingEdge) {
  final itemLeadingEdgeAbsolute = leadingEdge.abs();
  final fullHeight = itemLeadingEdgeAbsolute + trailingEdge;
  final heightPercent = fullHeight / 100;
  return itemLeadingEdgeAbsolute / heightPercent;
}
