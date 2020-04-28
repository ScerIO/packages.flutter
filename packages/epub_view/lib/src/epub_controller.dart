part of 'epub_view.dart';

class EpubReaderController {
  _EpubReaderViewState _epubReaderViewState;
  List<EpubReaderChapter> _cacheTableOfContents;

  final BehaviorSubject<bool> _loadedStreamController = BehaviorSubject<bool>();

  final BehaviorSubject<EpubChapterViewValue> _valueStreamController =
      BehaviorSubject<EpubChapterViewValue>();

  final BehaviorSubject<List<EpubReaderChapter>>
      _tableOfContentsStreamController =
      BehaviorSubject<List<EpubReaderChapter>>();

  EpubChapterViewValue get currentValue => _epubReaderViewState?._currentValue;

  Stream<bool> get bookLoadedStream => _loadedStreamController.stream;

  bool get isBookLoaded => _epubReaderViewState?._initialized;

  Stream<EpubChapterViewValue> get currentValueStream =>
      _valueStreamController.stream;

  Stream<List<EpubReaderChapter>> get tableOfContentsStream =>
      _tableOfContentsStreamController.stream;

  void jumpTo({@required int index, double alignment = 0}) =>
      _epubReaderViewState?._itemScrollController?.jumpTo(
        index: index,
        alignment: alignment,
      );

  Future<void> scrollTo({
    @required int index,
    Duration duration = const Duration(milliseconds: 250),
    double alignment = 0,
    Curve curve = Curves.linear,
  }) =>
      _epubReaderViewState?._itemScrollController?.scrollTo(
        index: index,
        duration: duration,
        alignment: alignment,
        curve: curve,
      );

  void gotoEpubCfi(
    String epubCfi, {
    double alignment = 0,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) {
    _epubReaderViewState?._gotoEpubCfi(
      epubCfi,
      alignment: alignment,
      duration: duration,
      curve: curve,
    );
  }

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
        index += 1;
        acc.add(EpubReaderChapter(next.Title, _getChapterStartIndex(index)));
        for (final subChapter in next.SubChapters) {
          index += 1;
          acc.add(EpubReaderSubChapter(
              subChapter.Title, _getChapterStartIndex(index)));
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
      _loadedStreamController.sink.add(value);
      if (value) {
        _epubReaderViewState._actualChapter.stream.listen((chapter) {
          _valueStreamController.sink.add(chapter);
        });
        _tableOfContentsStreamController.sink.add(tableOfContents());
      }
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
