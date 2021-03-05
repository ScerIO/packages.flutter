import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

class Entry {
  Entry({@required this.path})
      : name = p.basename(path),
        extension = p.extension(path).replaceFirst('.', '');

  final String name, path, extension;

  @override
  String toString() => 'Entry(name: $name, path: $path)';
}

class ExplorerFile extends Entry {
  ExplorerFile({
    @required String path,
    this.size,
  }) : super(path: path);

  /// Size in bytes, optional
  final int size;
}

class ExplorerDirectory extends Entry {
  ExplorerDirectory({@required String path}) : super(path: path);
}
