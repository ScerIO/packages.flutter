import 'dart:io';

const String pdfjsVersion = '4.6.82';

const String findString = '<body>';
const String _template = """$findString
  <script src='https://cdn.jsdelivr.net/npm/pdfjs-dist@4.6.82/build/pdf.min.mjs' type='module'></script>
  <script type='module'>
  var { pdfjsLib } = globalThis;
  pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdn.jsdelivr.net/npm/pdfjs-dist@4.6.82/build/pdf.worker.mjs';

  var pdfRenderOptions = {
    cMapUrl: 'https://cdn.jsdelivr.net/npm/pdfjs-dist@4.6.82/cmaps/',
    cMapPacked: true,
  }
  </script>""";

void main(List<String> args) async {
  stdout.writeln('[Modify web/index.hml by addition pdfjs]');

  final htmlFile = File('web/index.html');

  if (!await htmlFile.exists()) {
    stdout.writeln('Cannot find web/index.html');
    exit(1);
  }

  final String document = await htmlFile.readAsString();

  if (document.contains('pdfRenderOptions')) {
    stdout.writeln('Already installed, checking version consistency');

    final VersionConsistencyChecker checker =
        VersionConsistencyChecker(expectedVersion: '4.6.82');
    if (checker.checkVersion(document)) {
      stdout.writeln('Version is consistent');

      exit(2);
    } else {
      stdout.writeln('Version is inconsistent, fixing version');
      final resultDocument = checker.fixVersion(document);
      await htmlFile.writeAsString(resultDocument);
      stdout.writeln('Installation successful');

      exit(0);
    }
  }

  final resultDocument = document.replaceFirst(findString, _template);
  await htmlFile.writeAsString(resultDocument);

  stdout.writeln('installation successfully');
}

class VersionConsistencyChecker {
  static final RegExp versionRegex = RegExp(r'pdfjs-dist@(\d+\.\d+\.\d+)');

  final String expectedVersion;

  VersionConsistencyChecker({required this.expectedVersion});

  bool checkVersion(final String indexContent) {
    if (versionRegex.hasMatch(indexContent)) {
      final Iterable<RegExpMatch> matches =
          versionRegex.allMatches(indexContent);

      for (final match in matches) {
        if (match.group(1) != expectedVersion) {
          return false;
        }
      }
    }

    return true;
  }

  String fixVersion(final String indexContent) {
    return indexContent.replaceAll(versionRegex, 'pdfjs-dist@$expectedVersion');
  }
}
