import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class EpubCfiGenerator {
  String input;

  String generateCompleteCFI(
      String packageDocumentCFIComponent, String contentDocumentCFIComponent) {
    return 'epubcfi(' +
        packageDocumentCFIComponent +
        contentDocumentCFIComponent +
        ')';
  }

  String generatePackageDocumentCFIComponent() {}

  String generateElementCFIComponent() {}

  String createCFIElementSteps() {}
}
