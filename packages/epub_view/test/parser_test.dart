import 'package:epub_view/src/data/epub_cfi/epub_cfi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fragment parse - empty', () async {
    final parser = EpubCfiParser();
    CfiResult? result;
    try {
      result = parser.parse('', 'fragment');
    } catch (e) {
      expect(e, CfiSyntaxException(['\"epubcfi(\"'], null, 0, 1, 1));
    }

    expect(result, null);
  });

  test('fragment parse - null', () async {
    final parser = EpubCfiParser();
    CfiResult? result;
    try {
      result = parser.parse(null, null);
    } catch (e) {
      expect(e, CfiSyntaxException(['\"epubcfi(\"'], null, 0, 1, 1));
    }

    expect(result, null);
  });

  test('fragment parse - path', () async {
    final parser = EpubCfiParser();
    final result = parser.parse(
        'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/1:3[xx,y])', 'fragment');

    final localPath = CfiLocalPath(
      termStep: CfiTerminus(
        type: 'textTerminus',
        offsetValue: 3,
        textAssertion: CfiTextLocationAssertion(
          type: 'textLocationAssertion',
          csv: CfiCsv(type: 'csv', preAssertion: 'xx', postAssertion: 'y'),
          parameter:
              CfiParameter(type: 'parameter', lHSValue: null, rHSValue: null),
        ),
      ),
      steps: [
        CfiStep(type: 'indexStep', idAssertion: 'chap01ref', stepLength: 4),
        CfiStep(type: 'indirectionStep', idAssertion: 'body01', stepLength: 4),
        CfiStep(type: 'indexStep', idAssertion: 'para05', stepLength: 10),
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 1),
      ],
    );

    expect(
      result,
      CfiFragment(
          type: 'CFIAST',
          range: null,
          path: CfiPath(
            type: 'path',
            path: CfiStep(type: 'indexStep', stepLength: 6, idAssertion: null),
            localPath: localPath,
          )),
    );
  });

  test('fragment parse - range', () async {
    final parser = EpubCfiParser();
    final result = parser.parse(
        'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05],/2/1:1,/3:4)',
        'fragment');

    final localPath = CfiLocalPath(
      termStep: CfiTerminus(
          type: 'textTerminus', offsetValue: null, textAssertion: null),
      steps: [
        CfiStep(type: 'indexStep', idAssertion: 'chap01ref', stepLength: 4),
        CfiStep(type: 'indirectionStep', idAssertion: 'body01', stepLength: 4),
        CfiStep(type: 'indexStep', idAssertion: 'para05', stepLength: 10),
      ],
    );

    final range1 = CfiLocalPath(
      termStep: CfiTerminus(
          type: 'textTerminus', offsetValue: 1, textAssertion: null),
      steps: [
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 2),
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 1),
      ],
    );

    final range2 = CfiLocalPath(
      termStep: CfiTerminus(
          type: 'textTerminus', offsetValue: 4, textAssertion: null),
      steps: [
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 3),
      ],
    );

    expect(
      result,
      CfiFragment(
          type: 'CFIAST',
          range: CfiRange(
            type: 'range',
            path: CfiStep(type: 'indexStep', stepLength: 6, idAssertion: null),
            localPath: localPath,
            range1: range1,
            range2: range2,
          ),
          path: null),
    );
  });

  test('fragment parse - example 1', () async {
    final parser = EpubCfiParser();
    final result = parser.parse(
        'epubcfi(/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]])', 'fragment');

    final localPath = CfiLocalPath(
      termStep: CfiTerminus(
        type: 'textTerminus',
        offsetValue: 3,
        textAssertion: CfiTextLocationAssertion(
          type: 'textLocationAssertion',
          csv: CfiCsv(type: 'csv', preAssertion: '2[1]', postAssertion: ''),
          parameter:
              CfiParameter(type: 'parameter', lHSValue: null, rHSValue: null),
        ),
      ),
      steps: [
        CfiStep(type: 'indexStep', idAssertion: 'chap05ref', stepLength: 14),
        CfiStep(type: 'indirectionStep', idAssertion: 'body01', stepLength: 4),
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 10),
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 2),
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 1),
      ],
    );

    expect(
      result,
      CfiFragment(
          type: 'CFIAST',
          range: null,
          path: CfiPath(
            type: 'path',
            path: CfiStep(type: 'indexStep', stepLength: 6, idAssertion: null),
            localPath: localPath,
          )),
    );
  });

  test('fragment parse - example 2', () async {
    final parser = EpubCfiParser();
    final result = parser.parse(
        'epubcfi(/6/4[chap01ref]!/4[body01]/16[svgimg])', 'fragment');

    final localPath = CfiLocalPath(
      termStep: CfiTerminus(
        type: 'textTerminus',
        offsetValue: null,
        textAssertion: null,
      ),
      steps: [
        CfiStep(type: 'indexStep', idAssertion: 'chap01ref', stepLength: 4),
        CfiStep(type: 'indirectionStep', idAssertion: 'body01', stepLength: 4),
        CfiStep(type: 'indexStep', idAssertion: 'svgimg', stepLength: 16),
      ],
    );

    expect(
      result,
      CfiFragment(
          type: 'CFIAST',
          range: null,
          path: CfiPath(
            type: 'path',
            path: CfiStep(type: 'indexStep', stepLength: 6, idAssertion: null),
            localPath: localPath,
          )),
    );
  });

  test('fragment parse - example 3', () async {
    final parser = EpubCfiParser();
    final result = parser.parse(
        'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/1:0)', 'fragment');

    final localPath = CfiLocalPath(
      termStep: CfiTerminus(
        type: 'textTerminus',
        offsetValue: 0,
        textAssertion: null,
      ),
      steps: [
        CfiStep(type: 'indexStep', idAssertion: 'chap01ref', stepLength: 4),
        CfiStep(type: 'indirectionStep', idAssertion: 'body01', stepLength: 4),
        CfiStep(type: 'indexStep', idAssertion: 'para05', stepLength: 10),
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 1),
      ],
    );

    expect(
      result,
      CfiFragment(
          type: 'CFIAST',
          range: null,
          path: CfiPath(
            type: 'path',
            path: CfiStep(type: 'indexStep', stepLength: 6, idAssertion: null),
            localPath: localPath,
          )),
    );
  });

  test('fragment parse - example 4', () async {
    final parser = EpubCfiParser();
    final result = parser.parse(
        'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:0)', 'fragment');

    final localPath = CfiLocalPath(
      termStep: CfiTerminus(
        type: 'textTerminus',
        offsetValue: 0,
        textAssertion: null,
      ),
      steps: [
        CfiStep(type: 'indexStep', idAssertion: 'chap01ref', stepLength: 4),
        CfiStep(type: 'indirectionStep', idAssertion: 'body01', stepLength: 4),
        CfiStep(type: 'indexStep', idAssertion: 'para05', stepLength: 10),
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 2),
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 1),
      ],
    );

    expect(
      result,
      CfiFragment(
          type: 'CFIAST',
          range: null,
          path: CfiPath(
            type: 'path',
            path: CfiStep(type: 'indexStep', stepLength: 6, idAssertion: null),
            localPath: localPath,
          )),
    );
  });

  test('fragment parse - example 5', () async {
    final parser = EpubCfiParser();
    final result = parser.parse(
        'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3)', 'fragment');

    final localPath = CfiLocalPath(
      termStep: CfiTerminus(
          type: 'textTerminus', offsetValue: 3, textAssertion: null),
      steps: [
        CfiStep(type: 'indexStep', idAssertion: 'chap01ref', stepLength: 4),
        CfiStep(type: 'indirectionStep', idAssertion: 'body01', stepLength: 4),
        CfiStep(type: 'indexStep', idAssertion: 'para05', stepLength: 10),
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 2),
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 1),
      ],
    );

    expect(
      result,
      CfiFragment(
          type: 'CFIAST',
          range: null,
          path: CfiPath(
            type: 'path',
            path: CfiStep(type: 'indexStep', stepLength: 6, idAssertion: null),
            localPath: localPath,
          )),
    );
  });

  test('fragment parse - example 6', () async {
    final parser = EpubCfiParser();
    final result = parser.parse(
        'epubcfi(/6/14[chap05ref]!/4[body01]/10/2/1:3)', 'fragment');

    final localPath = CfiLocalPath(
      termStep: CfiTerminus(
        type: 'textTerminus',
        offsetValue: 3,
        textAssertion: null,
      ),
      steps: [
        CfiStep(type: 'indexStep', idAssertion: 'chap05ref', stepLength: 14),
        CfiStep(type: 'indirectionStep', idAssertion: 'body01', stepLength: 4),
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 10),
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 2),
        CfiStep(type: 'indexStep', idAssertion: null, stepLength: 1),
      ],
    );

    expect(
      result,
      CfiFragment(
          type: 'CFIAST',
          range: null,
          path: CfiPath(
            type: 'path',
            path: CfiStep(type: 'indexStep', stepLength: 6, idAssertion: null),
            localPath: localPath,
          )),
    );
  });

  test('fragment parse - error at the beginning', () async {
    final parser = EpubCfiParser();
    CfiResult? result;
    try {
      result = parser.parse(
          'epubcfi(q/6/14[chap05ref]!/4[body01]/10/2/1:3)', 'fragment');
    } catch (e) {
      expect(e, CfiSyntaxException(['\"/\"'], 'q', 8, 1, 9));
    }

    expect(result, null);
  });

  test('fragment parse - error in the middle', () async {
    final parser = EpubCfiParser();
    CfiResult? result;
    try {
      result = parser.parse(
          'epubcfi(/6/14q[chap05ref]!/4[body01]/10/2/1:3)', 'fragment');
    } catch (e) {
      expect(
        e,
        CfiSyntaxException(
          ['\"!/\"', '\")\"', '\",\"', '\"/\"', '\":\"', '\"[\"', '[0-9]'],
          'q',
          13,
          1,
          14,
        ),
      );
    }

    expect(result, null);
  });

  test('fragment parse - error at the end', () async {
    final parser = EpubCfiParser();
    CfiResult? result;
    try {
      result = parser.parse(
          'epubcfi(/6/14[chap05ref]!/4[body01]/10/2/1:3)q', 'fragment');
    } catch (e) {
      expect(
          e, CfiSyntaxException(['\",\"', '\"[\"', '[0-9]'], 'q', 45, 1, 46));
    }

    expect(result, null);
  });
}
