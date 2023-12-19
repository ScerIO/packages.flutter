// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfx/pdfx.dart';
import 'package:pdfx/src/renderer/interfaces/platform.dart';
import 'package:pdfx/src/renderer/io/platform_method_channel.dart';

import 'image.dart';

const String _testFilePath = '/dev/test/file/path/file.pdf';
const String _testAssetPath = '/assets/file.pdf';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PdfxPlatform.instance = PdfxPlatformMethodChannel();
  final List<MethodCall> log = <MethodCall>[];
  PdfDocument? document;
  late Uint8List testData;

  setUpAll(() async {
    testData = Uint8List.fromList(imageBytes);

    const channel = MethodChannel('io.scer.pdf_renderer');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'open.document.file':
          return {
            'id': 'uuid-file',
            'pagesCount': 1,
          };
        case 'open.document.asset':
          return {
            'id': 'uuid-asset',
            'pagesCount': 2,
          };
        case 'open.document.data':
          return {
            'id': 'uuid-data',
            'pagesCount': 3,
          };
        case 'close.document':
          return null;
        case 'open.page':
          return {
            'id': 'page-id',
            'width': 720.0,
            'height': 1280.0,
          };
        case 'close.page':
          return null;
        case 'render':
          return {
            'width': methodCall.arguments['width'],
            'height': methodCall.arguments['height'],
            'path': 'test/image.png',
            'data': testData,
          };
        default:
          return null;
      }
    });
  });

  tearDown(log.clear);

  group('Open document', () {
    test('from file path', () async {
      if (kIsWeb) {
        expect(
          PdfDocument.openFile(_testFilePath),
          throwsA(isInstanceOf<PlatformNotSupportedException>()),
        );
      } else {
        final document = await PdfDocument.openFile(_testFilePath);
        expect(log, <Matcher>[
          isMethodCall(
            'open.document.file',
            arguments: _testFilePath,
          ),
        ]);
        expect(document.pagesCount, 1);
      }
    });

    test('from asset', () async {
      final document = await PdfDocument.openAsset(_testAssetPath);
      expect(log, <Matcher>[
        isMethodCall(
          'open.document.asset',
          arguments: _testAssetPath,
        ),
      ]);
      expect(document.pagesCount, 2);
      await document.close();
      expect(document.isClosed, isTrue);
    });

    test('from data', () async {
      document = await PdfDocument.openData(testData);
      expect(log, <Matcher>[
        isMethodCall(
          'open.document.data',
          arguments: testData,
        ),
      ]);
      expect(document!.pagesCount, 3);
    });
  });

  group('Page', () {
    late PdfPage page;

    test('open', () async {
      // page number 0 - not available
      expect(
        document!.getPage(0),
        throwsA(isInstanceOf<RangeError>()),
      );

      page = await document!.getPage(3);
      expect(log, <Matcher>[
        isMethodCall(
          'open.page',
          arguments: {
            'documentId': 'uuid-data',
            'page': 3,
          },
        ),
      ]);
      expect(page.pageNumber, 3);
      expect(page.height, 1280);
      expect(page.width, 720);

      expect(page.document, document);

      // page number 4 more than the document
      expect(
        document!.getPage(4),
        throwsA(isInstanceOf<RangeError>()),
      );
    });

    test('render', () async {
      final width = page.width * 2, height = page.height * 2;
      final pageImage = (await page.render(
        width: width,
        height: height,
        format: PdfPageImageFormat.jpeg,
        backgroundColor: '#ffffff',
        removeTempFile: false,
      ))!;

      expect(log, <Matcher>[
        isMethodCall(
          'render',
          arguments: {
            'pageId': page.id,
            'width': width,
            'height': height,
            'format': PdfPageImageFormat.jpeg.value,
            'backgroundColor': '#ffffff',
            'crop': false,
            'crop_x': null,
            'crop_y': null,
            'crop_height': null,
            'crop_width': null,
            'quality': 100,
            'forPrint': false,
          },
        ),
      ]);

      expect(pageImage.bytes, testData);
      expect(pageImage.format, PdfPageImageFormat.jpeg);
      expect(pageImage.width, width);
      expect(pageImage.height, height);
      expect(pageImage.pageNumber, page.pageNumber);
      expect(pageImage.quality, 100);
    });

    test('close', () async {
      await page.close();
      expect(page.isClosed, isTrue);
      expect(
        page.close,
        throwsA(isInstanceOf<PdfPageAlreadyClosedException>()),
      );
      expect(
        page.render(width: 1, height: 1, removeTempFile: false),
        throwsA(isInstanceOf<PdfPageAlreadyClosedException>()),
      );
    });
  });

  test('Close document', () async {
    await document!.close();
    expect(document!.isClosed, isTrue);
    expect(
      document!.close,
      throwsA(isInstanceOf<PdfDocumentAlreadyClosedException>()),
    );
    expect(
      document!.getPage(1),
      throwsA(isInstanceOf<PdfDocumentAlreadyClosedException>()),
    );
  });
}
