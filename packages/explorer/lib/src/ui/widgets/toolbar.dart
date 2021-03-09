import 'package:explorer/src/i18n/localization.dart';
import 'package:explorer/src/ui/provider.dart';
import 'package:explorer/src/ui/widgets/breadcrumbs.dart';
import 'package:explorer/src/ui/widgets/fixed_sliver_persistent_header_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Toolbar view for explorer builder
class ExplorerToolbar extends StatelessWidget {
  Future<String> openModal(BuildContext context, String labelText) async =>
      showDialog<String>(
        context: context,
        builder: (context) {
          final i18n = ExplorerLocalizations.of(context);

          String result;
          return AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            content: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: labelText,
                    ),
                    onChanged: (value) => result = value,
                  ),
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(i18n.cancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text(i18n.create),
                onPressed: () {
                  Navigator.of(context).pop(result);
                },
              )
            ],
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final _controller = ControllerProvider.of(context).explorerController;
    final i18n = ExplorerLocalizations.of(context);

    final safeTopPadding = MediaQuery.of(context).padding.top;
    return SliverPersistentHeader(
      pinned: true,
      delegate: FixedSliverPersistentHeaderDelegate(
        minHeight: 48 + safeTopPadding,
        maxHeight: 48 + safeTopPadding,
        child: SizedBox.expand(
          child: Material(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.only(top: safeTopPadding),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: ExplorerBreadCrumbs()),
                  VerticalDivider(indent: 8, endIndent: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: _controller.refresh,
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.add),
                        onSelected: (String value) async {
                          if (value == 'directory') {
                            final folderName =
                                await openModal(context, i18n.folderName);
                            _controller.newDirectory(folderName);
                          } else if (value == 'file') {
                            final fileName =
                                await openModal(context, i18n.fileName);
                            _controller.newFile(fileName);
                          } else if (value == 'upload') {
                            _controller.uploadLocalFiles();
                          }
                        },
                        tooltip: 'Add',
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'directory',
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.create_new_folder),
                                SizedBox(width: 16),
                                Text(i18n.newFolder),
                              ],
                            ),
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem<String>(
                            value: 'file',
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.note_add),
                                SizedBox(width: 16),
                                Text(i18n.newFile),
                              ],
                            ),
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem<String>(
                            value: 'upload',
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.upload_file),
                                SizedBox(width: 16),
                                Text(i18n.uploadFiles),
                              ],
                            ),
                            enabled: _controller.uploadFiles != null,
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
