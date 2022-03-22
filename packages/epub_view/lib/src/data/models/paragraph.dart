import 'package:html/dom.dart' as dom;

class Paragraph {
  Paragraph(this.element, this.chapterIndex);

  final dom.Element element;
  final int chapterIndex;
}
