part of 'pdf_view_pinch.dart';

typedef PdfViewPinchBuilder<T> = Widget Function(
  /// Build context
  BuildContext context,

  /// All passed builders
  PdfViewPinchBuilders<T> builders,

  /// Document loading state
  PdfLoadingState state,

  /// Loaded result builder
  WidgetBuilder loadedBuilder,

  /// Pdf document when he loaded
  PdfDocument? document,

  /// Error of pdf loading
  Exception? loadingError,
);

class PdfViewPinchBuilders<T> {
  /// Widget showing when pdf document loading
  final WidgetBuilder? documentLoaderBuilder;

  /// Widget showing when pdf page loading
  final WidgetBuilder? pageLoaderBuilder;

  /// Show document loading error message inside [PdfView]
  final Widget Function(BuildContext, Exception error)? errorBuilder;

  /// Root view builder
  final PdfViewPinchBuilder<T> builder;

  /// Additional options for builder
  final T options;

  const PdfViewPinchBuilders({
    required this.options,
    this.builder = _PdfViewPinchState._builder,
    this.documentLoaderBuilder,
    this.pageLoaderBuilder,
    this.errorBuilder,
  });
}
