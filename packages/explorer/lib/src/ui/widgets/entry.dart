import 'package:explorer/src/data/models/entry.dart';
import 'package:explorer/src/utils/icon_by_entry.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Entry view
class EntryExplorer extends StatefulWidget {
  const EntryExplorer({
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
  State<EntryExplorer> createState() => _EntryExplorerState();
}

class _EntryExplorerState extends State<EntryExplorer> {
  late Offset _tapDownPosition;

  @override
  Widget build(BuildContext context) => Listener(
        child: InkWell(
          // child: Flex(
          //   direction: Axis.vertical,
          //   // mainAxisAlignment: MainAxisAlignment.center,
          //   // crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     Flexible(
          //       flex: 2,
          //       child: Icon(
          //         iconByEntry(widget.entry),
          //         size: 48,
          //       ),
          //     ),
          //     SizedBox(height: 8),
          //     Flexible(
          //       flex: 1,
          //       child: Text(
          //         widget.entry.name,
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //   ],
          // ),
          onTap: widget.onPressed,
          onLongPress: () {
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;

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
          // child: Flex(
          //   direction: Axis.vertical,
          //   // mainAxisAlignment: MainAxisAlignment.center,
          //   // crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     Flexible(
          //       flex: 2,
          //       child: Icon(
          //         iconByEntry(widget.entry),
          //         size: 48,
          //       ),
          //     ),
          //     SizedBox(height: 8),
          //     Flexible(
          //       flex: 1,
          //       child: Text(
          //         widget.entry.name,
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //   ],
          // ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final iconTopOffset = (constraints.maxHeight - 48) / 4;
              return Stack(
                children: [
                  Positioned(
                    top: iconTopOffset,
                    width: constraints.maxWidth,
                    child: Icon(
                      iconByEntry(widget.entry),
                      size: 48,
                    ),
                  ),
                  // Align(
                  //   alignment: Alignment.center,
                  //   child: Icon(
                  //     iconByEntry(widget.entry),
                  //     size: 48,
                  //   ),
                  // ),
                  Positioned(
                    width: constraints.maxWidth,
                    // entry height / 2 + icon / 2 + padding
                    top: iconTopOffset + 48,
                    child: Text(
                      widget.entry.name,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        onPointerDown: (PointerDownEvent event) {
          if (!(event.kind == PointerDeviceKind.mouse &&
              event.buttons == kSecondaryMouseButton)) {
            return;
          }

          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;

          widget.onLongPress!(RelativeRect.fromLTRB(
            event.position.dx,
            event.position.dy,
            overlay.size.width - event.position.dx,
            overlay.size.height - event.position.dy,
          ));
        },
      );
}
