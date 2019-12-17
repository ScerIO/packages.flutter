import 'package:flutter/widgets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
export 'package:native_pdf_renderer/native_pdf_renderer.dart';
export 'package:extended_image/extended_image.dart';

typedef PDFViewPageBuilder = Widget Function(
  PDFPageImage pageImage,
  bool isCurrentIndex,
);
typedef PDFViewPageRenderer = Future<PDFPageImage> Function(PDFPage page);

/// Widget for viewing PDF documents
class PDFView extends StatefulWidget {
  const PDFView({
    @required this.document,
    this.controller,
    this.onPageChanged,
    this.loader = const SizedBox(),
    this.scrollDirection = Axis.horizontal,
    this.renderer = _render,
    Key key,
  })  : assert(document != null),
        builder = _pageBuilder,
        super(key: key);

  const PDFView.builder({
    @required this.document,
    @required this.builder,
    this.controller,
    this.onPageChanged,
    this.loader = const SizedBox(),
    this.scrollDirection = Axis.horizontal,
    this.renderer = _render,
    Key key,
  })  : assert(document != null),
        super(key: key);

  /// The document to be displayed
  final PDFDocument document;

  /// Widget showing pdf page loading
  final Widget loader;

  /// Page turning direction
  final Axis scrollDirection;

  /// Page builder. Available in PDFView.builder
  final PDFViewPageBuilder builder;

  /// Custom PdfRenderer options
  final PDFViewPageRenderer renderer;

  /// Page management
  final PageController controller;

  /// Called whenever the page in the center of the viewport changes
  final void Function(int page) onPageChanged;

  /// Default PdfRenderer options
  static Future<PDFPageImage> _render(PDFPage page) => page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PDFPageFormat.JPEG,
        backgroundColor: '#ffffff',
      );

  static const List<double> _doubleTapScales = <double>[1.0, 2.0];

  /// Default page builder
  static Widget _pageBuilder(PDFPageImage pageImage, bool isCurrentIndex) {
    Widget image = ExtendedImage.memory(
      pageImage.bytes,
      fit: BoxFit.fitWidth,
      mode: ExtendedImageMode.gesture,
      initGestureConfigHandler: (_) => GestureConfig(
        minScale: 1,
        animationMinScale: .75,
        maxScale: 2,
        animationMaxScale: 2.5,
        speed: 1,
        inertialSpeed: 100,
        inPageView: true,
        initialScale: 1.0,
        cacheGesture: false,
      ),
      onDoubleTap: (ExtendedImageGestureState state) {
        ///you can use define pointerDownPosition as you can,
        ///default value is double tap pointer down position.
        final pointerDownPosition = state.pointerDownPosition;
        final begin = state.gestureDetails.totalScale;
        double end;

        if (begin == _doubleTapScales[0]) {
          end = _doubleTapScales[1];
        } else {
          end = _doubleTapScales[0];
        }

        state.handleDoubleTap(
          scale: end,
          doubleTapPosition: pointerDownPosition,
        );
      },
    );
    if (isCurrentIndex) {
      image = Hero(
        tag: 'pdf_view' + pageImage.pageNumber.toString(),
        child: image,
      );
    }
    return image;
  }

  @override
  _PDFViewState createState() => _PDFViewState();
}

class _PDFViewState extends State<PDFView> {
  final Map<int, PDFPageImage> _pages = {};
  PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    if (widget.controller != null) {
      _currentIndex = widget.controller.initialPage;
    } else {
      _pageController = PageController(initialPage: 0);
    }
    super.initState();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<PDFPageImage> _getPageImage(int pageIndex) async {
    if (_pages[pageIndex] != null) {
      return _pages[pageIndex];
    }

    final page = await widget.document.getPage(pageIndex + 1);

    try {
      _pages[pageIndex] = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PDFPageFormat.JPEG,
        backgroundColor: '#ffffff',
      );
    } finally {
      await page.close();
    }

    return _pages[pageIndex];
  }

  @override
  Widget build(BuildContext context) => ExtendedImageGesturePageView.builder(
        itemBuilder: (BuildContext context, int index) =>
            FutureBuilder<PDFPageImage>(
          future: _getPageImage(index),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return widget.builder(_pages[index], index == _currentIndex);
            }

            return widget.loader;
          },
        ),
        itemCount: widget.document.pagesCount,
        onPageChanged: (int index) {
          _currentIndex = index;
          widget.onPageChanged?.call(index + 1);
        },
        controller: widget.controller ?? _pageController,
        scrollDirection: widget.scrollDirection,
      );
}
