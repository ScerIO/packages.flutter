import 'dart:io';

const findString = '<body>';

const _template = """$findString
  <script src="https://cdn.jsdelivr.net/npm/pdfjs-dist@4.6.82/build/pdf.min.mjs" type="module"></script>
  <script type="module">
  var { pdfjsLib } = globalThis;
  pdfjsLib.GlobalWorkerOptions.workerSrc = "https://cdn.jsdelivr.net/npm/pdfjs-dist@4.6.82/build/pdf.worker.mjs";

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

  final document = await htmlFile.readAsString();

  if (document.contains('pdfRenderOptions')) {
    stdout.writeln('Already installed, operation aborted');
    exit(2);
  }

  final resultDocument = document.replaceFirst(findString, _template);
  await htmlFile.writeAsString(resultDocument);

  stdout.writeln('installation successfully');
}
