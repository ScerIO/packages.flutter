import 'models/entry.dart';

abstract class NavigatorExplorer {
  String get entryPath;
  String get currentPath;

  Future<List<Entry>> go(String path);

  Future<ExplorerDirectory> newDirectory(String name);

  Future<ExplorerFile> newFile(String name);

  Future<void> remove(Entry name);

  Future<void> copy(Entry from, Entry to);
}
