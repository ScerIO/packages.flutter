import 'entry.dart';

class ExplorerState {
  const ExplorerState({
    this.path,
    this.entries,
  });

  final String? path;
  final List<Entry>? entries;
}

abstract class ExplorerAction {}

class ExplorerActionEmpty extends ExplorerAction {}

class ExplorerActionCopy extends ExplorerAction {
  ExplorerActionCopy({
    this.from,
  });

  final List<Entry>? from;
}

class ExplorerActionMove extends ExplorerAction {
  ExplorerActionMove({
    this.from,
  });

  final List<Entry>? from;
}
