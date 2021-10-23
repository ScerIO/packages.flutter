import 'models/entry.dart';

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
  Future<void> remove(Entry entry);

  /// Copy file or dir
  Future<void> copy(Entry from, Entry to);
}
