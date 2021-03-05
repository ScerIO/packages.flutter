# explorer

Universal explorer UI for navigate files, ftp, etc

Support custom providers and any platforms

## Getting Started

In your flutter project add the dependency:

[![pub package](https://img.shields.io/pub/v/explorer.svg)](https://pub.dartlang.org/packages/explorer)

```yaml
dependencies:
  flutter_color: any
```

## Examples

```dart
_controller = ExplorerController(
  navigator: IoNavigatorExplorer(
    entryPath: _server.serverDirectory,
  ),
  uploadFiles: uploadFiles,
  filePressed: (file) {
    if (file.size > 200000) {
      final snackBar =
          SnackBar(content: Text('Can\'t open files with size > 200kb'));

      // Find the Scaffold in the widget tree and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (file.extension.contains(RegExp(r'^(phar|dat)$'))) {
      final snackBar = SnackBar(
          content: Text('Can\'t open files with extensions: ' +
              ' phar|dat'));

      // Find the Scaffold in the widget tree and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    Navigator.of(context).pushNamed(
      EditorScreen.routeName,
      arguments: EditorScreenArguments(property: file),
    );
  },
)

Explorer(
  controller: _controller,
  builder: (_) => [
    ExplorerToolbar(translate: toolbarTranslate),
    ExplorerActionView(translate: _actionTranslate),
    ExplorerFilesGridView(translate: filesTranslate),
  ],
)
```
