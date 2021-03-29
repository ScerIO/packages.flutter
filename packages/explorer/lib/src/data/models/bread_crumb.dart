import 'package:path/path.dart' as p;

class PathBreadCrumb {
  PathBreadCrumb({required this.path}) : name = p.basename(path);

  final String name, path;

  @override
  String toString() => '$runtimeType{name: $name, path: $path}';
}
