# explorer

Universal flexibility explorer UI for navigate files, ftp, etc.

Support custom providers and any platforms

## Showcase

| Context menu              | Actions                    | New & Upload                 |
| ---                       | ---                        | ---                          |
|![](https://raw.githubusercontent.com/ScerIO/packages.flutter/main/packages/explorer/example/media/1.0/context.jpg?raw=true)  | ![](https://raw.githubusercontent.com/ScerIO/packages.flutter/main/packages/explorer/example/media/1.0/actions.jpg?raw=true)  | ![](https://raw.githubusercontent.com/ScerIO/packages.flutter/main/packages/explorer/example/media/1.0/new.jpg?raw=true)  |

## Getting Started

In your flutter project add the dependency:

[![pub package](https://img.shields.io/pub/v/explorer.svg)](https://pub.dartlang.org/packages/explorer)

```yaml
dependencies:
  explorer: any
```

import
```dart
/// Main import
import 'package:explorer/explorer.dart';

/// Import for [IoExplorerProvider]. 
/// Does work only IO (NOT WORK ON WEB)
import 'package:explorer/explorer_io.dart';
```

## Api overview

### ExplorerController
| Parameter  | Description                                                                                        | Required | Default |
|------------|----------------------------------------------------------------------------------------------------|----------|---------|
| provider   | An entity responsible for navigating the file structure of any type, ex. IoExplorerProvider for io | [x]      | -       |

### Explorer
| Parameter        | Description                                                                       | Required | Default |
|------------------|-----------------------------------------------------------------------------------|----------|---------|
| controller       | ExplorerController initialized instance                                           | [x]      | -       |
| builder          | Builder callback for fully customize UI                                           | [x]      | -       |
| bottomBarBuilder | Additional builder for bottom bar                                                 | [ ]      | -       |
| uploadFiles      | Callback called on tap upload files action, (action show only if callback exist!) | [ ]      | -       |
| filePressed      | Callback called file pressed                                                      | [ ]      | -       |

### ExplorerToolbar

_Top toolbar with breadcrumbs & actions_

### ExplorerActionView
_Action view with actual command (Copy / move here etc.)_

### ExplorerFilesGridView
_Show files as grid_

## Examples

### Simple example
_See full at [example dir](/example/lib/main.dart)_
```dart
/// Initialize controller in initState
_controller = ExplorerController(
  provider: IoExplorerProvider(
    entryPath: '/path/to/entry', // For IO explorer pass some entry path
  ),
)

Explorer(
  controller: _controller,

  // Customize UI by Explorer & you own widgets!
  builder: (_) => [
    ExplorerToolbar(),
    ExplorerActionView(),
    ExplorerFilesGridView(),
  ],
  // Callback called on file at explorer pressed
  filePressed: (file) {
    if (file.size > 200000) {
      final snackBar =
          SnackBar(content: Text('Can\'t open files with size > 200kb'));

      // Find the Scaffold in the widget tree and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
  }
)
```

### Custom provider
_You need implement `ExplorerProvider` and pass result to `ExplorerController` as provider. You can make any provider: ftp, rest api, etc._

```dart
abstract class ExplorerProvider {
  /// Explorer starts path
  String get entryPath;

  /// Explorer actual path
  String get currentPath;

  /// Navigate to specific path
  Future<List<Entry>> go(String path);

  /// Create new directory at [currentPath]
  Future<ExplorerDirectory> newDirectory(String name);

  /// Create new file at [currentPath]
  Future<ExplorerFile> newFile(String name);

  /// Recursive remove file or dir at [currentPath]
  Future<void> remove(Entry name);

  /// Copy file or dir
  Future<void> copy(Entry from, Entry to);
}
```
