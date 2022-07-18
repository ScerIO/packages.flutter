import 'dart:async';

import 'package:explorer/src/data/provider.dart';
import 'package:explorer/src/ui/provider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:universal_platform/universal_platform.dart';
import 'data/models/bread_crumb.dart';
import 'data/models/entry.dart';
import 'data/models/state.dart';

part 'data/controller.dart';

typedef ExplorerBuilder = List<Widget> Function(BuildContext context);

class Explorer extends StatefulWidget {
  const Explorer({
    required this.controller,
    required this.builder,
    this.bottomBarBuilder,
    this.filePressed,
    this.uploadFiles,
    Key? key,
  }) : super(key: key);

  /// Explorer controller
  final ExplorerController controller;

  /// Main UI builder
  final ExplorerBuilder builder;

  /// Additional builder for bottom bar
  final WidgetBuilder? bottomBarBuilder;

  final Future<List<Entry>> Function()? uploadFiles;

  final void Function(ExplorerFile)? filePressed;

  @override
  State<Explorer> createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer>
    with SingleTickerProviderStateMixin {
  ScrollController? _scrollController;

  @override
  void initState() {
    widget.controller._attach(this);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Explorer oldWidget) {
    widget.controller._attach(this);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    widget.controller._detach();
    super.deactivate();
  }

  @override
  void dispose() {
    widget.controller._detach();
    _scrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ControllerProvider(
        explorerController: widget.controller,
        scrollController: _scrollController,
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: widget.controller.refresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: widget.builder(context),
                ),
              ),
            ),
            if (widget.bottomBarBuilder != null)
              widget.bottomBarBuilder!(context),
          ],
        ),
      );
}
