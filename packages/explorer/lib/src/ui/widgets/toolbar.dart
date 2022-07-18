import 'package:explorer/src/i18n/localization.dart';
import 'package:explorer/src/ui/provider.dart';
import 'package:explorer/src/ui/widgets/breadcrumbs.dart';
import 'package:explorer/src/ui/widgets/fixed_sliver_persistent_header_delegate.dart';
import 'package:flutter/material.dart';

Widget _defaultContainerBuilder(Widget child) => Material(
      elevation: 4,
      child: child,
    );

/// Toolbar view for explorer builder
class ExplorerToolbar extends StatelessWidget {
  const ExplorerToolbar({
    Key? key,
    this.containerBuilder = _defaultContainerBuilder,
  }) : super(key: key);

  final Widget Function(Widget child) containerBuilder;

  Future<String?> openModal(BuildContext context, String labelText) async =>
      showDialog<String>(
        context: context,
        builder: (context) {
          final i18n = ExplorerLocalizations.of(context)!;

          String? result;
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
    final controller = ControllerProvider.of(context)!.explorerController;
    final i18n = ExplorerLocalizations.of(context);

    final safeTopPadding = MediaQuery.of(context).padding.top;

    final content = Padding(
      padding: EdgeInsets.only(top: safeTopPadding),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: ExplorerBreadCrumbs()),
          const VerticalDivider(indent: 8, endIndent: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.refresh,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.add),
                onSelected: (String value) async {
                  if (value == 'directory') {
                    final folderName =
                        await openModal(context, i18n!.folderName);
                    controller.newDirectory(folderName!);
                  } else if (value == 'file') {
                    final fileName = await openModal(context, i18n!.fileName);
                    controller.newFile(fileName!);
                  } else if (value == 'upload') {
                    controller.uploadLocalFiles();
                  }
                },
                tooltip: 'Add',
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'directory',
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.create_new_folder),
                        const SizedBox(width: 16),
                        Text(i18n!.newFolder),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'file',
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.note_add),
                        const SizedBox(width: 16),
                        Text(i18n.newFile),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'upload',
                    enabled: controller.hasUploadFilesCallback,
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.upload_file),
                        const SizedBox(width: 16),
                        Text(i18n.uploadFiles),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );

    return SliverPersistentHeader(
      pinned: true,
      delegate: FixedSliverPersistentHeaderDelegate(
        minHeight: 48 + safeTopPadding,
        maxHeight: 48 + safeTopPadding,
        child: SizedBox.expand(
          child: containerBuilder(content),
        ),
      ),
    );
  }
}
