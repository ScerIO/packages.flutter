import 'package:flutter_test/flutter_test.dart';
import 'package:epub_view/src/parser/epub_cfi.dart';

void main() {
  test('fragment parse - empty', () async {
    final parser = EpubCfiParser();
    final result = parser.parse('epubcfi()', 'fragment');

    expect(result, null);
  });

  test('fragment parse - path', () async {
    final parser = EpubCfiParser();
    // final result = parser.parse(
    //     'epubcfi(/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]])', 'fragment');
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
          cfiRange: null,
          cfiPath: CfiPath(
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
          cfiRange: CfiRange(
            type: 'range',
            path: CfiStep(type: 'indexStep', stepLength: 6, idAssertion: null),
            localPath: localPath,
            range1: range1,
            range2: range2,
          ),
          cfiPath: null),
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
          cfiRange: null,
          cfiPath: CfiPath(
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
          cfiRange: null,
          cfiPath: CfiPath(
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
          cfiRange: null,
          cfiPath: CfiPath(
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
          cfiRange: null,
          cfiPath: CfiPath(
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
          cfiRange: null,
          cfiPath: CfiPath(
            type: 'path',
            path: CfiStep(type: 'indexStep', stepLength: 6, idAssertion: null),
            localPath: localPath,
          )),
    );
  });
}
