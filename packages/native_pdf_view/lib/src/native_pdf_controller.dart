part of 'native_pdf_view.dart';

/// Pages control
class PdfController {
  PdfController({
    @required this.document,
    this.initialPage = 1,
    this.viewportFraction = 1.0,
  })  : assert(initialPage != null),
        assert(viewportFraction != null),
        assert(viewportFraction > 0.0);

  /// Document future for showing in [PdfView]
  Future<PdfDocument> document;

  /// The page to show when first creating the [PdfView].
  final int initialPage;

  /// The fraction of the viewport that each page should occupy.
  ///
  /// Defaults to 1.0, which means each page fills the viewport in the scrolling
  /// direction.
  final double viewportFraction;

  _PdfViewState _pdfViewState;
  PageController _pageController;
  PdfDocument _document;

  /// Actual showed page
  int get page => (_pdfViewState?._currentIndex ?? 0) + 1;

  /// Count of all pages in document
  int get pagesCount => _document?.pagesCount;

  /// Changes which page is displayed in the controlled [PdfView].
  ///
  /// Jumps the page position from its current value to the given value,
  /// without animation, and without checking if the new value is in range.
  void jumpToPage(int page) =>
      _pageController.jumpToPage(page - 1);

  /// Animates the controlled [PdfView] from the current page to the given page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> animateToPage(
    int page, {
    @required Duration duration,
    @required Curve curve,
  }) =>
      _pageController.animateToPage(
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
    @required Duration duration,
    @required Curve curve,
  }) =>
      _pageController.animateToPage(_pageController.page.round() + 1,
          duration: duration, curve: curve);

  /// Animates the controlled [PdfView] to the previous page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> previousPage({
    @required Duration duration,
    @required Curve curve,
  }) =>
      _pageController.animateToPage(_pageController.page.round() - 1,
          duration: duration, curve: curve);

  /// Load document
  Future<void> loadDocument(Future<PdfDocument> documentFuture) {
    if (_pdfViewState != null) {
      return null;
    }
    _pdfViewState._changeLoadingState(_PdfViewLoadingState.loading);
    return _loadDocument(documentFuture);
  }

  Future<void> _loadDocument(Future<PdfDocument> documentFuture) async {
    assert(_pdfViewState != null);
    if (!await hasSupport()) {
      _pdfViewState
        .._loadingError = Exception(
            'This device does not support the display of PDF documents')
        .._changeLoadingState(_PdfViewLoadingState.success);
      return;
    }

    try {
      _document = await documentFuture;
      _pdfViewState._changeLoadingState(_PdfViewLoadingState.success);
    } catch (error) {
      _pdfViewState
        .._loadingError = error
        .._changeLoadingState(_PdfViewLoadingState.success);
    }
  }

  void _attach(_PdfViewState pdfViewState) {
    if (_pdfViewState != null) {
      return;
    }

    _pageController = PageController(
      initialPage: initialPage - 1,
      viewportFraction: viewportFraction,
    );

    _pdfViewState = pdfViewState;

    if (_document == null) {
      _loadDocument(document);
    }
  }

  void _detach() {
    _pdfViewState = null;
  }

  void dispose() {}
}
