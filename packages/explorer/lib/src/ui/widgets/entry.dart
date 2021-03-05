import 'package:explorer/src/data/models/entry.dart';
import 'package:explorer/src/utils/icon_by_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EntryExplorer extends StatefulWidget {
  EntryExplorer({
    @required this.entry,
    this.onPressed,
    this.onLongPress,
    Key key,
  }) : super(key: key);

  final Entry entry;
  final VoidCallback onPressed;
  final void Function(RelativeRect position) onLongPress;

  @override
  _EntryExplorerState createState() => _EntryExplorerState();
}

class _EntryExplorerState extends State<EntryExplorer> {
  Offset _tapDownPosition;

  @override
  Widget build(BuildContext context) => InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(iconByEntry(widget.entry), size: 48),
            SizedBox(height: 8),
            Text(
              widget.entry.name,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onTap: widget.onPressed,
        onLongPress: () {
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject();

          widget.onLongPress(RelativeRect.fromLTRB(
            _tapDownPosition.dx,
            _tapDownPosition.dy,
            overlay.size.width - _tapDownPosition.dx,
            overlay.size.height - _tapDownPosition.dy,
          ));
        },
        onTapDown: (TapDownDetails details) {
          _tapDownPosition = details.globalPosition;
        },
      );
}
