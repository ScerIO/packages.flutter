import 'package:flutter/widgets.dart';
import 'package:pdfx/src/renderer/interfaces/document.dart';
import 'package:pdfx/src/renderer/interfaces/page.dart';
import 'package:pdfx/src/viewer/base/base_pdf_builders.dart';
import 'package:pdfx/src/viewer/base/base_pdf_controller.dart';
import 'package:pdfx/src/viewer/pdf_page_image_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:synchronized/synchronized.dart';

part 'pdf_controller.dart';
part 'pdf_view_builders.dart';

typedef PDfViewPageRenderer = Future<PdfPageImage?> Function(PdfPage page);

final Lock _lock = Lock();

/// Widget for viewing PDF documents
class PdfView extends StatefulWidget {
  const PdfView({
    required this.controller,
    this.onPageChanged,
    this.onDocumentLoaded,
    this.onDocumentError,
    this.builders = const PdfViewBuilders<DefaultBuilderOptions>(
      options: DefaultBuilderOptions(),
    ),
    this.renderer = _render,
    this.scrollDirection = Axis.horizontal,
    this.pageSnapping = true,
    this.physics,
    this.backgroundDecoration = const BoxDecoration(),
    Key? key,
  }) : super(key: key);

  /// Page management
  final PdfController controller;

  /// Called whenever the page in the center of the viewport changes
  final void Function(int page)? onPageChanged;

  /// Called when a document is loaded
  final void Function(PdfDocument document)? onDocumentLoaded;

  /// Called when a document loading error
  final void Function(Object error)? onDocumentError;

  /// Builders
  final PdfViewBuilders builders;

  /// Custom PdfRenderer options
  final PDfViewPageRenderer renderer;

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
        format: PdfPageImageFormat.jpeg,
        backgroundColor: '#ffffff',
      );

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  final Map<int, PdfPageImage?> _pages = {};
  PdfController get _controller => widget.controller;
  Exception? _loadingError;

  @override
  void initState() {
    super.initState();
    _controller._attach(this);
    _controller.loadingState.addListener(() {
      switch (_controller.loadingState.value) {
        case PdfLoadingState.loading:
          _pages.clear();
          break;
        case PdfLoadingState.success:
          widget.onDocumentLoaded?.call(_controller._document!);
          break;
        case PdfLoadingState.error:
          widget.onDocumentError?.call(_loadingError!);
          break;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller._detach();
    super.dispose();
  }

  Future<PdfPageImage> _getPageImage(int pageIndex) =>
      _lock.synchronized<PdfPageImage>(() async {
        if (_pages[pageIndex] != null) {
          return _pages[pageIndex]!;
        }

        final page = await _controller._document!.getPage(pageIndex + 1);

        try {
          _pages[pageIndex] = await widget.renderer(page);
        } finally {
          await page.close();
        }

        return _pages[pageIndex]!;
      });

  @override
  Widget build(BuildContext context) {
    return widget.builders.builder(
      context,
      widget.builders,
      _controller.loadingState.value,
      _buildLoaded,
      _controller._document,
      _loadingError,
    );
  }

  static Widget _builder(
    BuildContext context,
    PdfViewBuilders builders,
    PdfLoadingState state,
    WidgetBuilder loadedBuilder,
    PdfDocument? document,
    Exception? loadingError,
  ) {
    final Widget content = () {
      switch (state) {
        case PdfLoadingState.loading:
          return KeyedSubtree(
            key: const Key('pdfx.root.loading'),
            child: builders.documentLoaderBuilder?.call(context) ??
                const SizedBox(),
          );
        case PdfLoadingState.error:
          return KeyedSubtree(
            key: const Key('pdfx.root.error'),
            child: builders.errorBuilder?.call(context, loadingError!) ??
                Center(child: Text(loadingError.toString())),
          );
        case PdfLoadingState.success:
          return KeyedSubtree(
            key: Key('pdfx.root.success.${document!.id}'),
            child: loadedBuilder(context),
          );
      }
    }();

    final defaultBuilder = builders as PdfViewBuilders<DefaultBuilderOptions>;
    final options = defaultBuilder.options;

    return AnimatedSwitcher(
      duration: options.loaderSwitchDuration,
      transitionBuilder: options.transitionBuilder,
      child: content,
    );
  }

  /// Default page builder
  static PhotoViewGalleryPageOptions _pageBuilder(
    BuildContext context,
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

  Widget _buildLoaded(BuildContext context) => PhotoViewGallery.builder(
        builder: (context, index) => widget.builders.pageBuilder(
          context,
          _getPageImage(index),
          index,
          _controller._document!,
        ),
        itemCount: _controller._document?.pagesCount ?? 0,
        loadingBuilder: (_, __) =>
            widget.builders.pageLoaderBuilder?.call(context) ??
            const SizedBox(),
        backgroundDecoration: widget.backgroundDecoration,
        pageController: _controller._pageController,
        onPageChanged: (index) {
          final pageNumber = index + 1;
          _controller.pageListenable.value = pageNumber;
          widget.onPageChanged?.call(pageNumber);
        },
        scrollDirection: widget.scrollDirection,
        scrollPhysics: widget.physics,
      );
}
