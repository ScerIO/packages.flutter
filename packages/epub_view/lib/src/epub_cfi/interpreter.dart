import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:epub_view/epub_view.dart';
import 'package:epub_view/src/epub_cfi/parser.dart';

class EpubCfiInterpreter {
  Element searchLocalPathForHref(Element currElement,
      EpubPackage packageDocument, CfiLocalPath localPathNode) {
    // Interpret the first local_path node,
    // which is a set of steps and and a terminus condition
    int stepNum = 0;
    CfiStep nextStepNode;
    Element _currElement = currElement;

    for (stepNum = 0; stepNum < localPathNode.steps.length; stepNum++) {
      nextStepNode = localPathNode.steps[stepNum];
      if (nextStepNode.type == 'indexStep') {
        _currElement = interpretIndexStepNode(nextStepNode, _currElement);
      } else if (nextStepNode.type == 'indirectionStep') {
        _currElement = interpretIndirectionStepNode(nextStepNode, _currElement);
      }
    }

    return null;
  }

  Element interpretIndexStepNode(CfiStep indexStepNode, Element currElement) {
    // Check node type; throw error if wrong type
    if (indexStepNode == null || indexStepNode.type != 'indexStep') {
      throw FlutterError('$indexStepNode: expected index step node');
    }

    // Index step
    final stepTarget = getNextNode(indexStepNode.stepLength, currElement);

    // Check the id assertion, if it exists
    if ((indexStepNode.idAssertion ?? '').isNotEmpty) {
      if (!targetIdMatchesIdAssertion(stepTarget, indexStepNode.idAssertion)) {
        throw FlutterError(
            // ignore: lines_longer_than_80_chars
            '${indexStepNode.idAssertion}: ${stepTarget.attributes['id']} Id assertion failed');
      }
    }

    return stepTarget;
  }

  Element interpretIndirectionStepNode(
      CfiStep indirectionStepNode, Element currElement) {
    // Check node type; throw error if wrong type
    if (indirectionStepNode == null ||
        indirectionStepNode.type != 'indirectionStep') {
      throw FlutterError(
          '$indirectionStepNode: expected indirection step node');
    }

    // Indirection step
    final stepTarget = getNextNode(indirectionStepNode.stepLength, currElement);

    // Check the id assertion, if it exists
    if (indirectionStepNode.idAssertion != null) {
      if (!targetIdMatchesIdAssertion(
          stepTarget, indirectionStepNode.idAssertion)) {
        throw FlutterError(
            // ignore: lines_longer_than_80_chars
            '${indirectionStepNode.idAssertion}: ${stepTarget.attributes['id']} Id assertion failed');
      }
    }

    return stepTarget;
  }

  bool targetIdMatchesIdAssertion(Element foundNode, String idAssertion) =>
      foundNode.attributes.containsKey('id') &&
      foundNode.attributes['id'] == idAssertion;

  Element getNextNode(int cfiStepValue, Element currNode) {
    if (cfiStepValue % 2 == 0) {
      return elementNodeStep(cfiStepValue, currNode);
    }

    return null;
  }

  Element elementNodeStep(int cfiStepValue, Element currNode) {
    final int targetNodeIndex = ((cfiStepValue / 2) - 1).toInt();
    final int numElements = currNode.children.length;

    if (targetNodeIndex >= numElements) {
      throw RangeError.range(targetNodeIndex, 0, numElements - 1);
    }

    return currNode.children[targetNodeIndex];
  }
}
