part of '../explorer.dart';

class ExplorerController {
  ExplorerController({
    @required this.navigator,
    this.filePressed,
    this.uploadFiles,
  });

  final Future<List<Entry>> Function() uploadFiles;
  final NavigatorExplorer navigator;
  final void Function(ExplorerFile) filePressed;

  // _ExplorerState _explorerState;
  final StreamController<ExplorerState> _files =
      StreamController<ExplorerState>.broadcast();
  Stream<ExplorerState> get stream => _files.stream;

  String get entryPath => navigator.entryPath;
  String get currentPath => navigator.currentPath;

  final StreamController<ExplorerAction> _actions =
      StreamController<ExplorerAction>.broadcast();
  Stream<ExplorerAction> get actionStream => _actions.stream;

  void _attach(_ExplorerState _explorerState) {
    assert(_explorerState != null);
    // this._explorerState = _explorerState;
    navigator.go(navigator.entryPath).then((entries) {
      _files.add(ExplorerState(
        path: navigator.currentPath,
        entries: entries,
      ));
    });
    _actions.add(ExplorerActionEmpty());
  }

  void _detach() {
    // _explorerState = null;
  }

  void dispose() {
    _files?.close();
    _actions?.close();
  }

  Future<void> uploadLocalFiles() async {
    if (uploadFiles == null) {
      return;
    }

    final entries = await uploadFiles();
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

  Future<void> copy(Entry from, Entry to) async => navigator.copy(from, to);

  Future<void> goEntry(Entry entry) async {
    if (entry is ExplorerDirectory) {
      return go(entry.path);
    } else {
      filePressed(entry);
    }
  }

  Future<void> go(String path) async {
    final entries = await navigator.go(path);
    _files.add(ExplorerState(
      path: navigator.currentPath,
      entries: entries,
    ));
  }

  Future<void> newDirectory(String name) async {
    await navigator.newDirectory(name);
    return refresh();
  }

  Future<void> newFile(String name) async {
    await navigator.newFile(name);
    return refresh();
  }

  Future<void> remove(Entry entry) async {
    await navigator.remove(entry);
    return refresh();
  }

  Future<void> refresh() => go(currentPath);

  List<PathBreadCrumb> get breadCrumbs {
    var delimiter = '/';
    if (UniversalPlatform.isWindows) {
      delimiter = '\\';
    }
    final names = currentPath.replaceFirst(entryPath, '').split(delimiter)
      ..removeWhere((element) => element?.isEmpty);
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
