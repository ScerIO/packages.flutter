import 'package:explorer/src/data/models/entry.dart';
import 'package:explorer/src/utils/icon_by_entry.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Entry view
class EntryExplorer extends StatefulWidget {
  EntryExplorer({
    required this.entry,
    this.onPressed,
    this.onLongPress,
    Key? key,
  }) : super(key: key);

  /// Entry
  final Entry entry;

  /// Action on pressed
  final VoidCallback? onPressed;

  /// Action on long tap
  final void Function(RelativeRect position)? onLongPress;

  @override
  _EntryExplorerState createState() => _EntryExplorerState();
}

class _EntryExplorerState extends State<EntryExplorer> {
  late Offset _tapDownPosition;

  @override
  Widget build(BuildContext context) => Listener(
        child: InkWell(
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
                Overlay.of(context)!.context.findRenderObject() as RenderBox;

            widget.onLongPress!(RelativeRect.fromLTRB(
              _tapDownPosition.dx,
              _tapDownPosition.dy,
              overlay.size.width - _tapDownPosition.dx,
              overlay.size.height - _tapDownPosition.dy,
            ));
          },
          onTapDown: (TapDownDetails details) {
            _tapDownPosition = details.globalPosition;
          },
        ),
        onPointerDown: (PointerDownEvent event) {
          if (!(event.kind == PointerDeviceKind.mouse &&
              event.buttons == kSecondaryMouseButton)) {
            return;
          }

          final RenderBox overlay =
              Overlay.of(context)!.context.findRenderObject() as RenderBox;

          widget.onLongPress!(RelativeRect.fromLTRB(
            event.position.dx,
            event.position.dy,
            overlay.size.width - event.position.dx,
            overlay.size.height - event.position.dy,
          ));
          print('!!!! RB clicked');
        },
      );
}
