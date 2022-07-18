import 'package:auto_animated/auto_animated.dart';
import 'package:explorer/src/data/models/entry.dart';
import 'package:explorer/src/data/models/state.dart';
import 'package:explorer/src/explorer.dart';
import 'package:explorer/src/i18n/localization.dart';
import 'package:explorer/src/ui/provider.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'entry.dart';

class ExplorerFilesGridView extends StatefulWidget {
  const ExplorerFilesGridView({Key? key}) : super(key: key);

  @override
  State<ExplorerFilesGridView> createState() => _ExplorerFilesGridViewState();
}

class _ExplorerFilesGridViewState extends State<ExplorerFilesGridView> {
  late ExplorerController _controller;
  final int listItemCount = 4;

  final Duration listShowItemDuration = const Duration(milliseconds: 250);

  @override
  void initState() {
    _controller = ControllerProvider.of(context)!.explorerController;

    super.initState();
  }

  ExplorerState get _initialData => ExplorerState(
        path: _controller.entryPath,
        entries: [],
      );

  Future<void> _showContextMenu(RelativeRect position, Entry entry) async {
    final i18n = ExplorerLocalizations.of(context)!;

    final result = await showMenu(
      context: context,
      position: position,
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: 'open',
          child: Row(
            children: <Widget>[
              const Icon(Icons.launch),
              const SizedBox(width: 16),
              Text(i18n.actionMenuOpen),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: <Widget>[
              const Icon(Icons.content_copy),
              const SizedBox(width: 16),
              Text(i18n.actionMenuCopy),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'cut',
          child: Row(
            children: <Widget>[
              const Icon(Icons.content_cut),
              const SizedBox(width: 16),
              Text(i18n.actionMenuCut),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: <Widget>[
              const Icon(Icons.delete),
              const SizedBox(width: 16),
              Text(i18n.actionMenuDelete),
            ],
          ),
        ),
      ],
    );
    if (result == 'open') {
      _controller.goEntry(entry);
    } else if (result == 'delete') {
      _controller.remove(entry);
    } else if (result == 'copy') {
      _controller.copyEntriesRequest([entry]);
    } else if (result == 'cut') {
      _controller.moveEntriesRequest([entry]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final i18n = ExplorerLocalizations.of(context);

    var crossAxisCount = 3;
    if (size.width >= 600 && size.width < 800) {
      crossAxisCount = 4;
    } else if (size.width >= 800 && size.width < 1000) {
      crossAxisCount = 5;
    } else if (size.width >= 1000 && size.width < 1200) {
      crossAxisCount = 6;
    } else if (size.width >= 1200) {
      crossAxisCount = 7;
    }

    return StreamBuilder<ExplorerState>(
      initialData: _initialData,
      stream: _controller.stream,
      builder: (_, snapshot) {
        final entries = snapshot.data!.entries!;
        return SliverStack(
          insetOnOverlap: false, // defaults to false
          children: <Widget>[
            if (entries.isEmpty)
              SliverFillRemaining(
                child: Center(child: Text(i18n!.empty)),
              ),
            LiveSliverGrid(
              controller: ControllerProvider.of(context)!.scrollController!,
              showItemInterval: const Duration(milliseconds: 25),
              showItemDuration: const Duration(milliseconds: 125),
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index, animation) {
                final entry = entries[index];

                return FadeTransition(
                  opacity: Tween<double>(
                    begin: 0,
                    end: 1,
                  ).animate(animation),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.025),
                      end: Offset.zero,
                    ).animate(animation),
                    child: EntryExplorer(
                      entry: entry,
                      onPressed: () => _controller.goEntry(entry),
                      onLongPress: (position) =>
                          _showContextMenu(position, entry),
                    ),
                  ),
                );
              },

              // w400 = 3
              // w1200 = 6
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
            )
          ],
        );
      },
    );
  }
}
