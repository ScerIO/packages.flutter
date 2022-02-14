import 'package:flutter/widgets.dart';
import 'package:pdfx/src/viewer/base/base_pdf_controller.dart';

typedef PdfPageNumberBuilder = Widget Function(
  BuildContext context,
  PdfLoadingState loadingState,
  int page,
  int? pagesCount,
);

class PdfPageNumber extends StatelessWidget {
  const PdfPageNumber({
    required this.controller,
    required this.builder,
    Key? key,
  }) : super(key: key);

  final BasePdfController controller;
  final PdfPageNumberBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PdfLoadingState>(
      valueListenable: controller.loadingState,
      builder: (context, loadingState, child) => ValueListenableBuilder<int>(
        valueListenable: controller.pageListenable,
        builder: (context, page, child) => builder(
          context,
          loadingState,
          page,
          controller.pagesCount,
        ),
      ),
    );
  }
}
