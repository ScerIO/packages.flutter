part of 'pdf_view.dart';

typedef PdfViewPageBuilder = PhotoViewGalleryPageOptions Function(
  /// Build context
  BuildContext context,

  /// Page image model
  Future<PdfPageImage> pageImage,

  /// page index
  int index,

  /// pdf document
  PdfDocument document,
);

typedef PdfViewBuilder<T> = Widget Function(
  /// Build context
  BuildContext context,

  /// All passed builders
  PdfViewBuilders<T> builders,

  /// Document loading state
  PdfLoadingState state,

  /// Loaded result builder
  WidgetBuilder loadedBuilder,

  /// Pdf document when he loaded
  PdfDocument? document,

  /// Error of pdf loading
  Exception? loadingError,
);

class PdfViewBuilders<T> {
  /// Widget showing when pdf document loading
  final WidgetBuilder? documentLoaderBuilder;

  /// Widget showing when pdf page loading
  final WidgetBuilder? pageLoaderBuilder;

  /// Show document loading error message inside [PdfView]
  final Widget Function(BuildContext, Exception error)? errorBuilder;

  /// Page builder
  final PdfViewPageBuilder pageBuilder;

  /// Root view builder
  final PdfViewBuilder<T> builder;

  /// Additional options for builder
  final T options;

  const PdfViewBuilders({
    required this.options,
    this.builder = _PdfViewState._builder,
    this.documentLoaderBuilder,
    this.pageLoaderBuilder,
    this.pageBuilder = _PdfViewState._pageBuilder,
    this.errorBuilder,
  });
}
