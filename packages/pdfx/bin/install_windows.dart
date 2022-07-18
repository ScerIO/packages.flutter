import 'dart:io';

const _template = 'set(PDFIUM_VERSION "4638" CACHE STRING "")';

void main(List<String> args) async {
  stdout.writeln('[Modify windows/CMakeLists.txt pdfium version parameter]');

  final cMakeFile = File('windows/CMakeLists.txt');

  if (!await cMakeFile.exists()) {
    stdout.writeln('Cannot find windows/CMakeLists.txt');
    exit(1);
  }

  final document = await cMakeFile.readAsString();

  if (document.contains('PDFIUM_VERSION')) {
    stdout.writeln('Already installed, operation aborted');
    exit(2);
  }

  await cMakeFile.writeAsString('$document\n\n$_template');

  stdout.writeln('installation successfully');
}
