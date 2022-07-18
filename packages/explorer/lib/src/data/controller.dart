part of '../explorer.dart';

class ExplorerController {
  ExplorerController({
    required this.provider,
  });

  /// An entity responsible for navigating the file
  /// structure of any type, ex. IoExplorerProvider for io
  final ExplorerProvider provider;

  _ExplorerState? _explorerState;

  // _ExplorerState _explorerState;
  final StreamController<ExplorerState> _files =
      StreamController<ExplorerState>.broadcast();
  Stream<ExplorerState> get stream => _files.stream;

  String get entryPath => provider.entryPath;
  String get currentPath => provider.currentPath;

  final StreamController<ExplorerAction> _actions =
      StreamController<ExplorerAction>.broadcast();
  Stream<ExplorerAction> get actionStream => _actions.stream;

  void _attach(_ExplorerState explorerState) {
    _explorerState = explorerState;
    provider.go(provider.entryPath).then((entries) {
      if (_files.isClosed) {
        return;
      }
      _files.add(ExplorerState(
        path: provider.currentPath,
        entries: entries,
      ));
    });
    _actions.add(ExplorerActionEmpty());
  }

  void _detach() {
    _explorerState = null;
  }

  void dispose() {
    _files.close();
    _actions.close();
  }

  bool get hasUploadFilesCallback => _explorerState!.widget.uploadFiles != null;

  Future<void> uploadLocalFiles() async {
    if (_explorerState!.widget.uploadFiles == null) {
      return;
    }

    final entries = await _explorerState!.widget.uploadFiles!();
    for (final entry in entries) {
      await copy(entry, Entry(path: p.join(currentPath, entry.name)));
    }
    return refresh();
  }

  void copyEntriesRequest(List<Entry> entries) {
    _actions.add(ExplorerActionCopy(from: entries));
  }

  void copyEntriesConfirm(List<Entry> entries) async {
    for (final entry in entries) {
      await copy(entry, Entry(path: p.join(currentPath, entry.name)));
    }
    _actions.add(ExplorerActionEmpty());
    return refresh();
  }

  void moveEntriesRequest(List<Entry> entries) {
    _actions.add(ExplorerActionMove(from: entries));
  }

  void moveEntriesConfirm(List<Entry> entries) async {
    for (final entry in entries) {
      await copy(entry, Entry(path: p.join(currentPath, entry.name)));
      await remove(entry);
    }
    _actions.add(ExplorerActionEmpty());
    return refresh();
  }

  void cancelAction() {
    _actions.add(ExplorerActionEmpty());
  }

  Future<void> copy(Entry from, Entry to) async => provider.copy(from, to);

  Future<void> goEntry(Entry entry) async {
    if (entry is ExplorerDirectory) {
      return go(entry.path);
    } else {
      _explorerState!.widget.filePressed!(entry as ExplorerFile);
    }
  }

  Future<void> go(String path) async {
    final entries = await provider.go(path);
    _files.add(ExplorerState(
      path: provider.currentPath,
      entries: entries,
    ));
  }

  Future<void> newDirectory(String name) async {
    await provider.newDirectory(name);
    return refresh();
  }

  Future<void> newFile(String name) async {
    await provider.newFile(name);
    return refresh();
  }

  Future<void> remove(Entry entry) async {
    await provider.remove(entry);
    return refresh();
  }

  Future<void> refresh() => go(currentPath);

  List<PathBreadCrumb> get breadCrumbs {
    var delimiter = '/';
    if (UniversalPlatform.isWindows) {
      delimiter = '\\';
    }
    final names = currentPath.replaceFirst(entryPath, '').split(delimiter)
      ..removeWhere((element) => element.isEmpty);
    final crumbs = <PathBreadCrumb>[
      PathBreadCrumb(path: entryPath),
    ];

    for (final name in names) {
      final String path = (crumbs.isNotEmpty)
          ? p.join(crumbs.last.path, name)
          : p.join(entryPath, name);
      crumbs.add(PathBreadCrumb(
        path: path,
      ));
    }

    return crumbs;
  }
}
