import 'package:explorer/src/explorer.dart';
import 'package:flutter/widgets.dart';

class ControllerProvider extends InheritedWidget {
  const ControllerProvider({
    required this.explorerController,
    required this.scrollController,
    required Widget child,
    Key? key,
  }) : super(
          key: key,
          child: child,
        );

  final ExplorerController explorerController;
  final ScrollController? scrollController;

  @override
  bool updateShouldNotify(ControllerProvider old) =>
      explorerController != old.explorerController ||
      scrollController != old.scrollController;

  static ControllerProvider? of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<ControllerProvider>();
}
