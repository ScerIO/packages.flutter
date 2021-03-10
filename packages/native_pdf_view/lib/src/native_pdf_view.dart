import 'package:flutter/widgets.dart';
import 'package:native_pdf_view/src/pdf_page_image_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:synchronized/synchronized.dart';

export 'package:native_pdf_renderer/native_pdf_renderer.dart';

part 'native_pdf_controller.dart';

typedef PDFViewPageBuilder = PhotoViewGalleryPageOptions Function(
  /// Page image model
  Future<PdfPageImage> pageImage,

  /// page index
  int index,

  /// pdf document
  PdfDocument document,
);

typedef PDFViewPageRenderer = Future<PdfPageImage?> Function(PdfPage page);

final Lock _lock = Lock();

/// Widget for viewing PDF documents
class PdfView extends StatefulWidget {
  const PdfView({
    required this.controller,
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
    this.backgroundDecoration = const BoxDecoration(),
    this.loaderSwitchDuration = const Duration(seconds: 1),
    Key? key,
  }) : super(key: key);

  ///
  final Duration loaderSwitchDuration;

  /// Page management
  final PdfController controller;

  /// Called whenever the page in the center of the viewport changes
  final void Function(int page)? onPageChanged;

  /// Called when a document is loaded
  final void Function(PdfDocument document)? onDocumentLoaded;

  /// Called when a document loading error
  final void Function(Object error)? onDocumentError;

  /// Widget showing when pdf document loading
  final Widget? documentLoader;

  /// Widget showing when pdf page loading
  final Widget? pageLoader;

  /// Page builder
  final PDFViewPageBuilder pageBuilder;

  /// Show document loading error message inside [PdfView]
  final Widget Function(Exception error)? errorBuilder;

  /// Custom PdfRenderer options
  final PDFViewPageRenderer renderer;

  /// Page turning direction
  final Axis scrollDirection;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  final bool pageSnapping;

  /// Pdf widget page background decoration
  final BoxDecoration? backgroundDecoration;

  /// Determines the physics of a [PdfView] widget.
  final ScrollPhysics? physics;

  /// Default PdfRenderer options
  static Future<PdfPageImage?> _render(PdfPage page) => page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageFormat.JPEG,
        backgroundColor: '#ffffff',
      );

  /// Default page builder
  static PhotoViewGalleryPageOptions _pageBuilder(
    Future<PdfPageImage> pageImage,
    int index,
    PdfDocument document,
  ) =>
      PhotoViewGalleryPageOptions(
        imageProvider: PdfPageImageProvider(
          pageImage,
          index,
          document.id,
        ),
        minScale: PhotoViewComputedScale.contained * 1,
        maxScale: PhotoViewComputedScale.contained * 3.0,
        initialScale: PhotoViewComputedScale.contained * 1.0,
        heroAttributes: PhotoViewHeroAttributes(tag: '${document.id}-$index'),
      );

  @override
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> with SingleTickerProviderStateMixin {
  final Map<int, PdfPageImage?> _pages = {};
  late _PdfViewLoadingState _loadingState;
  Exception? _loadingError;
  late int _currentIndex;

  @override
  void initState() {
    _loadingState = _PdfViewLoadingState.loading;
    widget.controller._attach(this);
    _currentIndex = widget.controller._pageController!.initialPage;
    super.initState();
  }

  @override
  void dispose() {
    widget.controller._detach();
    super.dispose();
  }

  Future<PdfPageImage> _getPageImage(int pageIndex) =>
      _lock.synchronized<PdfPageImage>(() async {
        if (_pages[pageIndex] != null) {
          return _pages[pageIndex]!;
        }

        final page = await widget.controller._document!.getPage(pageIndex + 1);

        try {
          _pages[pageIndex] = await widget.renderer(page);
        } finally {
          await page.close();
        }

        return _pages[pageIndex]!;
      });

  void _changeLoadingState(_PdfViewLoadingState state) {
    if (state == _PdfViewLoadingState.loading) {
      _pages.clear();
    } else if (state == _PdfViewLoadingState.success) {
      widget.onDocumentLoaded?.call(widget.controller._document!);
    } else if (state == _PdfViewLoadingState.error) {
      widget.onDocumentError?.call(_loadingError!);
    }
    setState(() {
      _loadingState = state;
    });
  }

  Widget _buildLoaded() => PhotoViewGallery.builder(
        builder: (BuildContext context, int index) => widget.pageBuilder(
            _getPageImage(index), index, widget.controller._document!),
        itemCount: widget.controller._document!.pagesCount,
        loadingBuilder: (_, __) => widget.pageLoader ?? SizedBox(),
        backgroundDecoration: widget.backgroundDecoration,
        pageController: widget.controller._pageController,
        onPageChanged: (int index) {
          _currentIndex = index;
          widget.onPageChanged?.call(index + 1);
        },
        scrollDirection: widget.scrollDirection,
        scrollPhysics: widget.physics,
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
          child: widget.errorBuilder?.call(_loadingError!) ??
              Center(child: Text(_loadingError.toString())),
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
      duration: widget.loaderSwitchDuration,
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
