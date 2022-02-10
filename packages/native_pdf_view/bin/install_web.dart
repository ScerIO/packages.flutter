import 'dart:io';

const findString =
    '<script src="main.dart.js" type="application/javascript"></script>';

const _template =
    """<script src="https://cdn.jsdelivr.net/npm/pdfjs-dist@2.7.570/build/pdf.js" type="text/javascript"></script>
  <script type="text/javascript">
    pdfjsLib.GlobalWorkerOptions.workerSrc = "https://cdn.jsdelivr.net/npm/pdfjs-dist@2.7.570/build/pdf.worker.min.js";
    pdfRenderOptions = {
      cMapUrl: 'https://cdn.jsdelivr.net/npm/pdfjs-dist@2.7.570/cmaps/',
      cMapPacked: true,
    }
  </script>
  $findString""";

void main(List<String> args) async {
  stdout.writeln('[Modify web/index.hml by addition pdfjs]');

  final htmlFile = File('web/index.html');

  if (!htmlFile.existsSync()) {
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
