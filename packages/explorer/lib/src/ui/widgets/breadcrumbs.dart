import 'dart:async';

import 'package:explorer/src/data/models/state.dart';
import 'package:explorer/src/explorer.dart';
import 'package:explorer/src/ui/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

/// Location (path) breadcrumbs view for explorer builder
class ExplorerBreadCrumbs extends StatefulWidget {
  const ExplorerBreadCrumbs({Key? key}) : super(key: key);

  @override
  State<ExplorerBreadCrumbs> createState() => _ExplorerBreadCrumbsState();
}

class _ExplorerBreadCrumbsState extends State<ExplorerBreadCrumbs>
    with SingleTickerProviderStateMixin {
  late ExplorerController _controller;
  late AnimationController _animationController;
  ScrollController? _scrollController;
  StreamSubscription<ExplorerState>? _subscription;

  @override
  void initState() {
    _controller = ControllerProvider.of(context)!.explorerController;
    _scrollController = ScrollController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _subscription = _controller.stream.listen((state) {
      if (_controller.breadCrumbs.length == 1) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController!.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  ExplorerState get _initialData => ExplorerState(
        path: _controller.entryPath,
        entries: [],
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<ExplorerState>(
      initialData: _initialData,
      stream: _controller.stream,
      builder: (_, snapshot) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController!.hasClients) {
            _scrollController!
                .jumpTo(_scrollController!.position.maxScrollExtent);
          }
        });

        return BreadCrumb(
          overflow: ScrollableOverflow(controller: _scrollController),
          items: <BreadCrumbItem>[
            for (final crumb in _controller.breadCrumbs)
              BreadCrumbItem(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                content: Text(crumb.name, style: theme.textTheme.bodyMedium),
                onTap: () => _controller.go(crumb.path),
              ),
          ],
          divider: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}
