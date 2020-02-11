import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:epub_view/src/epub_cfi/parser.dart';

class EpubCfiInterpreter {
  Element searchLocalPathForHref(
      Element htmlElement, CfiLocalPath localPathNode) {
    // Interpret the first local_path node,
    // which is a set of steps and and a terminus condition
    CfiStep nextStepNode;
    Element currElement = htmlElement;

    for (int stepNum = 1; stepNum < localPathNode.steps.length; stepNum++) {
      nextStepNode = localPathNode.steps[stepNum];
      if (nextStepNode.type == 'indexStep') {
        currElement = interpretIndexStepNode(nextStepNode, currElement);
      } else if (nextStepNode.type == 'indirectionStep') {
        currElement = interpretIndirectionStepNode(nextStepNode, currElement);
      }
    }

    return currElement;
  }

  Element interpretIndexStepNode(CfiStep indexStepNode, Element currElement) {
    // Check node type; throw error if wrong type
    if (indexStepNode == null || indexStepNode.type != 'indexStep') {
      throw FlutterError('$indexStepNode: expected index step node');
    }

    // Index step
    final stepTarget = _getNextNode(indexStepNode.stepLength, currElement);

    // Check the id assertion, if it exists
    if ((indexStepNode.idAssertion ?? '').isNotEmpty) {
      if (!_targetIdMatchesIdAssertion(stepTarget, indexStepNode.idAssertion)) {
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
    final stepTarget =
        _getNextNode(indirectionStepNode.stepLength, currElement);

    // Check the id assertion, if it exists
    if (indirectionStepNode.idAssertion != null) {
      if (!_targetIdMatchesIdAssertion(
          stepTarget, indirectionStepNode.idAssertion)) {
        throw FlutterError(
            // ignore: lines_longer_than_80_chars
            '${indirectionStepNode.idAssertion}: ${stepTarget.attributes['id']} Id assertion failed');
      }
    }

    return stepTarget;
  }

  bool _targetIdMatchesIdAssertion(Element foundNode, String idAssertion) =>
      foundNode.attributes.containsKey('id') &&
      foundNode.attributes['id'] == idAssertion;

  Element _getNextNode(int cfiStepValue, Element currNode) {
    if (cfiStepValue % 2 == 0) {
      return _elementNodeStep(cfiStepValue, currNode);
    }

    return null;
  }

  Element _elementNodeStep(int cfiStepValue, Element currNode) {
    final int targetNodeIndex = ((cfiStepValue / 2) - 1).toInt();
    final int numElements = currNode.children.length;

    if (targetNodeIndex >= numElements) {
      throw RangeError.range(targetNodeIndex, 0, numElements - 1);
    }

    return currNode.children[targetNodeIndex];
  }
}
