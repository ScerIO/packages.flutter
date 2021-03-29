part of 'native_pdf_view.dart';

/// Pages control
class PdfController {
  PdfController({
    required this.document,
    this.initialPage = 1,
    this.viewportFraction = 1.0,
  }) : assert(viewportFraction > 0.0);

  /// Document future for showing in [PdfView]
  Future<PdfDocument> document;

  /// The page to show when first creating the [PdfView].
  final int initialPage;

  /// The fraction of the viewport that each page should occupy.
  ///
  /// Defaults to 1.0, which means each page fills the viewport in the scrolling
  /// direction.
  final double viewportFraction;

  _PdfViewState? _pdfViewState;
  PageController? _pageController;
  PdfDocument? _document;

  /// Actual showed page
  int get page => (_pdfViewState!._currentIndex) + 1;

  /// Count of all pages in document
  int get pagesCount => _document!.pagesCount;

  /// Changes which page is displayed in the controlled [PdfView].
  ///
  /// Jumps the page position from its current value to the given value,
  /// without animation, and without checking if the new value is in range.
  void jumpToPage(int page) => _pageController!.jumpToPage(page - 1);

  /// Animates the controlled [PdfView] from the current page to the given page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) =>
      _pageController!.animateToPage(
        page - 1,
        duration: duration,
        curve: curve,
      );

  /// Animates the controlled [PdfView] to the next page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> nextPage({
    required Duration duration,
    required Curve curve,
  }) =>
      _pageController!.animateToPage(_pageController!.page!.round() + 1,
          duration: duration, curve: curve);

  /// Animates the controlled [PdfView] to the previous page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> previousPage({
    required Duration duration,
    required Curve curve,
  }) =>
      _pageController!.animateToPage(_pageController!.page!.round() - 1,
          duration: duration, curve: curve);

  /// Load document
  Future<void> loadDocument(
    Future<PdfDocument> documentFuture, {
    int initialPage = 1,
  }) {
    _pdfViewState!._changeLoadingState(_PdfViewLoadingState.loading);
    return _loadDocument(documentFuture, initialPage: initialPage);
  }

  Future<void> _loadDocument(
    Future<PdfDocument> documentFuture, {
    int initialPage = 1,
  }) async {
    assert(_pdfViewState != null);

    if (!await hasSupport()) {
      _pdfViewState!
        .._loadingError = Exception(
            'This device does not support the display of PDF documents')
        .._changeLoadingState(_PdfViewLoadingState.error);
      return;
    }

    try {
      _reInitPageController(initialPage);

      _document = await documentFuture;
      _pdfViewState!._changeLoadingState(_PdfViewLoadingState.success);
    } catch (error) {
      _pdfViewState!
        .._loadingError =
            error is Exception ? error : Exception('Unknown error')
        .._changeLoadingState(_PdfViewLoadingState.error);
    }
  }

  void _reInitPageController(int initialPage) {
    _pageController?.dispose();
    _pageController = PageController(
      initialPage: initialPage - 1,
      viewportFraction: viewportFraction,
    );
  }

  void _attach(_PdfViewState pdfViewState) {
    if (_pdfViewState != null) {
      return;
    }

    _reInitPageController(initialPage);

    _pdfViewState = pdfViewState;

    if (_document == null) {
      _loadDocument(document, initialPage: initialPage);
    }
  }

  void _detach() {
    _pdfViewState = null;
  }

  void dispose() {
    _pageController?.dispose();
  }
}
