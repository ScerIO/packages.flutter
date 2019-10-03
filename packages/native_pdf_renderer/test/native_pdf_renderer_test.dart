import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';

const String _testFilePath = '/dev/test/file/path/file.pdf';
const String _testAssetPath = '/assets/file.pdf';
final Uint8List _testData = Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]);

void main() {
  final List<MethodCall> log = <MethodCall>[];
  final Map<String, bool> openedDocumentsIds = {};
  final Map<String, PDFDocument> openedDocuments = {};

  setUpAll(() async {
    MethodChannel('io.scer.pdf.renderer')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'open.document.file':
          openedDocumentsIds['uuid-file'] = true;
          return {
            'id': 'uuid-file',
            'pagesCount': 2,
          };
        case 'open.document.asset':
          openedDocumentsIds['uuid-asset'] = true;
          return {
            'id': 'uuid-asset',
            'pagesCount': 2,
          };
        case 'open.document.data':
          openedDocumentsIds['uuid-data'] = true;
          return {
            'id': 'uuid-data',
            'pagesCount': 2,
          };
        case 'close.document':
          openedDocumentsIds.remove(methodCall.arguments);
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(log.clear);

  test('Open document from file path', () async {
    final document = await PDFDocument.openFile(_testFilePath);
    expect(log, <Matcher>[
      isMethodCall(
        'open.document.file',
        arguments: _testFilePath,
      ),
    ]);
    expect(openedDocumentsIds['uuid-file'], isTrue);
    openedDocuments['file'] = document;
  });

  test('Open document from asset', () async {
    final document = await PDFDocument.openAsset(_testAssetPath);
    expect(log, <Matcher>[
      isMethodCall(
        'open.document.asset',
        arguments: _testAssetPath,
      ),
    ]);
    expect(openedDocumentsIds['uuid-asset'], isTrue);
    openedDocuments['asset'] = document;
  });

  test('Open document from data', () async {
    final document = await PDFDocument.openData(_testData);
    expect(log, <Matcher>[
      isMethodCall(
        'open.document.data',
        arguments: _testData,
      ),
    ]);
    expect(openedDocumentsIds['uuid-data'], isTrue);
    openedDocuments['data'] = document;
  });

  test('Close document', () async {
    await openedDocuments['asset'].close();
    expect(openedDocuments['asset'].isClosed, isTrue);
    await openedDocuments['data'].close();
    expect(openedDocuments['data'].isClosed, isTrue);
    expect(openedDocuments['asset'].close,
        throwsA(isInstanceOf<PdfDocumentAlreadyClosedException>()));
  });
}
