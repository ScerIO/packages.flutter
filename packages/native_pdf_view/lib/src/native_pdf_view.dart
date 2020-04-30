import 'package:flutter/widgets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:native_pdf_view/src/utils.dart';
import 'package:synchronized/synchronized.dart';
export 'package:native_pdf_renderer/native_pdf_renderer.dart';
export 'package:extended_image/extended_image.dart';

part 'native_pdf_controller.dart';

typedef PDFViewPageBuilder = Widget Function(
  /// Page image model
  PdfPageImage pageImage,

  /// true if page now showed
  bool isCurrentIndex,

  /// onDoubleTap Animation
  AnimationController animationController,
);

typedef PDFViewPageRenderer = Future<PdfPageImage> Function(PdfPage page);

final Lock _lock = Lock();

/// Widget for viewing PDF documents
class PdfView extends StatefulWidget {
  const PdfView({
    @required this.controller,
    this.onPageChanged,
    this.onDocumentLoaded,
    this.onDocumentError,
    this.documentLoader,
    this.pageLoader,
    this.pageBuilder = _pageBuilder,
    this.errorBuilder,
    this.renderer = _render,
    this.scrollDirection = Axis.horizontal,
    this.pageSnapping = true,
    this.physics,
    Key key,
  })  : assert(pageSnapping != null),
        assert(controller != null),
        assert(renderer != null),
        super(key: key);

  /// Page management
  final PdfController controller;

  /// Called whenever the page in the center of the viewport changes
  final void Function(int page) onPageChanged;

  /// Called when a document is loaded
  final void Function(PdfDocument document) onDocumentLoaded;

  /// Called when a document loading error
  final void Function(Exception error) onDocumentError;

  /// Widget showing when pdf document loading
  final Widget documentLoader;

  /// Widget showing when pdf page loading
  final Widget pageLoader;

  /// Page builder
  final PDFViewPageBuilder pageBuilder;

  /// Show document loading error message inside [PdfView]
  final Widget Function(Exception error) errorBuilder;

  /// Custom PdfRenderer options
  final PDFViewPageRenderer renderer;

  /// Page turning direction
  final Axis scrollDirection;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  final bool pageSnapping;

  /// Determines the physics of a [PdfView] widget.
  final ScrollPhysics physics;

  /// Default PdfRenderer options
  static Future<PdfPageImage> _render(PdfPage page) => page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageFormat.JPEG,
        backgroundColor: '#ffffff',
      );

  static const List<double> _doubleTapScales = <double>[1.0, 2.0, 3.0];

  /// Default page builder
  static Widget _pageBuilder(
    PdfPageImage pageImage,
    bool isCurrentIndex,
    AnimationController animationController,
  ) {
    Animation<double> _doubleTapAnimation;
    void Function() _animationListener;

    Widget image = ExtendedImage.memory(
      pageImage.bytes,
      key: Key(pageImage.hashCode.toString()),
      fit: BoxFit.contain,
      mode: ExtendedImageMode.gesture,
      initGestureConfigHandler: (_) => GestureConfig(
        minScale: 1,
        maxScale: 3.0,
        animationMinScale: .75,
        animationMaxScale: 3.0,
        speed: 1,
        inertialSpeed: 100,
        inPageView: true,
        initialScale: 1.0,
        cacheGesture: false,
      ),
      onDoubleTap: (ExtendedImageGestureState state) {
        final pointerDownPosition = state.pointerDownPosition;
        final begin = state.gestureDetails.totalScale;
        double end;

        _doubleTapAnimation?.removeListener(_animationListener);

        animationController
          ..stop()
          ..reset();

        if (begin == _doubleTapScales[0]) {
          end = _doubleTapScales[1];
        } else {
          if (begin == _doubleTapScales[1]) {
            end = _doubleTapScales[2];
          } else {
            end = _doubleTapScales[0];
          }
        }

        _animationListener = () {
          //print(_animation.value);
          state.handleDoubleTap(
              scale: _doubleTapAnimation.value,
              doubleTapPosition: pointerDownPosition);
        };
        _doubleTapAnimation = animationController
            .drive(Tween<double>(begin: begin, end: end))
              ..addListener(_animationListener);

        animationController.forward();
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
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> with SingleTickerProviderStateMixin {
  final Map<int, PdfPageImage> _pages = {};
  _PdfViewLoadingState _loadingState;
  Exception _loadingError;
  int _currentIndex;
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _loadingState = _PdfViewLoadingState.loading;
    widget.controller._attach(this);
    _currentIndex = widget.controller._pageController.initialPage ?? 0;
    super.initState();
  }

  @override
  void dispose() {
    widget.controller._detach();
    _animationController.dispose();
    super.dispose();
  }

  Future<PdfPageImage> _getPageImage(int pageIndex) =>
      _lock.synchronized<PdfPageImage>(() async {
        if (_pages[pageIndex] != null) {
          return _pages[pageIndex];
        }

        final page = await widget.controller._document.getPage(pageIndex + 1);

        try {
          _pages[pageIndex] = await widget.renderer(page);
        } finally {
          await page.close();
        }

        return _pages[pageIndex];
      });

  void _changeLoadingState(_PdfViewLoadingState state) {
    if (state == _PdfViewLoadingState.success) {
      widget.onDocumentLoaded?.call(widget.controller._document);
    } else if (state == _PdfViewLoadingState.error) {
      widget.onDocumentError?.call(_loadingError);
    }
    setState(() {
      _loadingState = state;
    });
  }

  Widget _buildLoaded() => ExtendedImageGesturePageView.builder(
        itemBuilder: (BuildContext context, int index) =>
            FutureBuilder<PdfPageImage>(
          future: _getPageImage(index),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return KeyedSubtree(
                key: Key('$runtimeType.page.'
                    '${widget.controller._document.hashCode}.'
                    '${_pages[index].pageNumber}'),
                child: widget.pageBuilder(
                  _pages[index],
                  index == _currentIndex,
                  _animationController,
                ),
              );
            }

            return KeyedSubtree(
              key: Key('$runtimeType.page.loading'),
              child: widget.pageLoader ?? SizedBox(),
            );
          },
        ),
        itemCount: widget.controller._document.pagesCount,
        onPageChanged: (int index) {
          _currentIndex = index;
          widget.onPageChanged?.call(index + 1);
        },
        controller: widget.controller?._pageController,
        scrollDirection: widget.scrollDirection,
        pageSnapping: widget.pageSnapping,
        physics: widget.physics,
      );

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (_loadingState) {
      case _PdfViewLoadingState.loading:
        content = KeyedSubtree(
          key: Key('$runtimeType.root.loading'),
          child: widget.documentLoader ?? SizedBox(),
        );
        break;
      case _PdfViewLoadingState.error:
        content = KeyedSubtree(
          key: Key('$runtimeType.root.error'),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: widget.errorBuilder?.call(_loadingError) ??
                Center(child: Text(_loadingError.toString())),
          ),
        );
        break;
      case _PdfViewLoadingState.success:
        content = KeyedSubtree(
          key: Key('$runtimeType.root.success'),
          child: _buildLoaded(),
        );
        break;
    }

    return AnimatedSwitcher(
      duration: Duration(seconds: 1),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: content,
    );
  }
}

enum _PdfViewLoadingState {
  loading,
  error,
  success,
}
