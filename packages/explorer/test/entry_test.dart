import 'package:explorer/explorer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Entry', () {
    test('derives name from path', () {
      final entry = Entry(path: '/home/user/documents/report.pdf');

      expect(entry.name, 'report.pdf');
      expect(entry.path, '/home/user/documents/report.pdf');
    });
  });

  group('ExplorerFile', () {
    test('derives extension from path', () {
      final file = ExplorerFile(
        path: '/home/user/documents/report.pdf',
        size: 1024,
      );

      expect(file.extension, 'pdf');
      expect(file.size, 1024);
    });

    test('extension is empty when the file has none', () {
      final file = ExplorerFile(path: '/home/user/documents/README');

      expect(file.extension, isEmpty);
    });
  });
}
