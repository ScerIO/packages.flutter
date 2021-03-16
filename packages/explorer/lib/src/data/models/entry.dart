import 'package:path/path.dart' as p;

class Entry {
  Entry({required this.path}) : name = p.basename(path);

  /// Entry name
  final String name;

  /// Entry location
  final String path;

  @override
  String toString() => 'Entry(name: $name, path: $path)';
}

class ExplorerFile extends Entry {
  ExplorerFile({
    required String path,
    this.size,
  })  : extension = p.extension(path).replaceFirst('.', ''),
        super(path: path);

  /// Size in bytes, optional
  final int? size;

  /// Entry extension (available for files)
  final String extension;
}

class ExplorerDirectory extends Entry {
  ExplorerDirectory({required String path}) : super(path: path);
}
