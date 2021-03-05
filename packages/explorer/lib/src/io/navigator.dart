import 'dart:io';

import 'package:io/io.dart';
import 'package:path/path.dart' as p;
import 'package:explorer/src/data/models/entry.dart';
import 'package:explorer/src/data/navigator.dart';

class IoNavigatorExplorer extends NavigatorExplorer {
  IoNavigatorExplorer({
    this.entryPath = '/',
  }) : currentPath = entryPath;

  @override
  final String entryPath;

  @override
  String currentPath;

  @override
  Future<List<Entry>> go(String path) async {
    final contents = Directory(path).listSync()
      ..sort((a, b) => a.path.compareTo(b.path));
    final dirs = <Entry>[];
    final files = <Entry>[];
    for (final entry in contents) {
      if (entry is File) {
        files.add(ExplorerFile(
          path: entry.path,
          size: entry.lengthSync(),
        ));
      } else if (entry is Directory) {
        dirs.add(ExplorerDirectory(
          path: entry.path,
        ));
      }
    }
    currentPath = path;
    return [...dirs, ...files];
  }

  @override
  Future<ExplorerDirectory> newDirectory(String name) async {
    final directory = Directory(p.join(currentPath, name));
    await directory.create();
    return ExplorerDirectory(
      path: directory.path,
    );
  }

  @override
  Future<ExplorerFile> newFile(String name) async {
    final file = File(p.join(currentPath, name));
    await file.create();
    return ExplorerFile(
      path: file.path,
      size: file.lengthSync(),
    );
  }

  @override
  Future<void> remove(Entry entry) async {
    final entityType = FileSystemEntity.typeSync(entry.path);
    if (entityType == FileSystemEntityType.directory) {
      return Directory(entry.path).delete(recursive: true);
    } else if (entityType == FileSystemEntityType.file) {
      return File(entry.path).delete(recursive: true);
    } else if (entityType == FileSystemEntityType.link) {
      return Link(entry.path).delete(recursive: true);
    }
  }

  @override
  Future<void> copy(Entry from, Entry to) async {
    final entityType = FileSystemEntity.typeSync(from.path);
    if (entityType == FileSystemEntityType.directory) {
      await copyPath(from.path, to.path);
    } else if (entityType == FileSystemEntityType.file) {
      await File(from.path).copy(to.path);
    }
  }
}
