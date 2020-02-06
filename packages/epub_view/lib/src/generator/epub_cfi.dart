import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class EpubCfiGenerator {
  EpubCfiGenerator(this.inputHtml) {
    document = parse(inputHtml);
  }

  String inputHtml;
  Document document;

  String generateCompleteCFI(
      String packageDocumentCFIComponent, String contentDocumentCFIComponent) =>
     'epubcfi(' +
        packageDocumentCFIComponent +
        contentDocumentCFIComponent +
        ')';

  String generatePackageDocumentCFIComponent(contentDocumentName, packageDocument, classBlacklist, elementBlacklist, idBlacklist) {
    // this.validateContentDocumentName(contentDocumentName);
    // this.validatePackageDocument(packageDocument, contentDocumentName);

    // Get the start node (itemref element) that references the content document
    // ignore: lines_longer_than_80_chars
    $itemRefStartNode = $("itemref[idref='" + contentDocumentName + "']", $(packageDocument));

    // ignore: lines_longer_than_80_chars
    // Create the steps up to the top element of the package document (the "package" element)
    // ignore: lines_longer_than_80_chars
    final String packageDocCFIComponent = _createCFIElementSteps($itemRefStartNode, 'package', classBlacklist, elementBlacklist, idBlacklist);

    // ignore: lines_longer_than_80_chars
    // Append an !; this assumes that a CFI content document CFI component will be appended at some point
    return packageDocCFIComponent + '!';
  }

  String generateElementCFIComponent(startElement, classBlacklist, elementBlacklist, idBlacklist) {
    var contentDocCFI;
    var $itemRefStartNode;
    var packageDocCFI;

    // this.validateStartElement(startElement);

    // ignore: lines_longer_than_80_chars
    // Call the recursive method to create all the steps up to the head element of the content document (the "html" element)
    // ignore: lines_longer_than_80_chars
    contentDocCFI = _createCFIElementSteps($(startElement), 'html', classBlacklist, elementBlacklist, idBlacklist);

    // Remove the ! 
    return contentDocCFI.substring(1, contentDocCFI.length);
  }

  String _createCFIElementSteps(Node $currNode, Element topLevelElement, classBlacklist, elementBlacklist, idBlacklist) {
    var $blacklistExcluded;
    var $parentNode;
    var currNodePosition;
    var idAssertion;
    var elementStep; 

    // Find position of current node in parent list
    // ignore: lines_longer_than_80_chars
    // $blacklistExcluded = Instructions.applyBlacklist($currNode.parent().children(), classBlacklist, elementBlacklist, idBlacklist);
    // $.each($blacklistExcluded, function (index, value) {
    //   if (this === $currNode[0]) {

    //     currNodePosition = index;

    //     // Break loop
    //     return false;
    //   }
    // });

    // Convert position to the CFI even-integer representation
    final int cfiPosition = (currNodePosition + 1) * 2;

    // Create CFI step with id assertion, if the element has an id
    if ($currNode.attr('id')) {
      elementStep = '/' + cfiPosition.toString() + '[' + $currNode.attr('id') + ']';
    }
    else {
      elementStep = '/' + cfiPosition.toString();
    }

    // ignore: lines_longer_than_80_chars
    // If a parent is an html element return the (last) step for this content document, otherwise, continue.
    // ignore: lines_longer_than_80_chars
    //   Also need to check if the current node is the top-level element. This can occur if the start node is also the
    //   top level element.
    $parentNode = $currNode.parent();
    if ($parentNode.is(topLevelElement) || $currNode.is(topLevelElement)) {

      // ignore: lines_longer_than_80_chars
      // If the top level node is a type from which an indirection step, add an indirection step character (!)
      // ignore: lines_longer_than_80_chars
      // REFACTORING CANDIDATE: It is possible that this should be changed to: if (topLevelElement = 'package') do
      // ignore: lines_longer_than_80_chars
      //   not return an indirection character. Every other type of top-level element may require an indirection
      //   step to navigate to, thus requiring that ! is always prepended. 
      if (topLevelElement == 'html') {
        return '!' + elementStep;
      }
      else {
        return elementStep;
      }
    }
    else {
      // ignore: lines_longer_than_80_chars
      return _createCFIElementSteps($parentNode, topLevelElement, classBlacklist, elementBlacklist, idBlacklist) + elementStep;
    }
  }
}
