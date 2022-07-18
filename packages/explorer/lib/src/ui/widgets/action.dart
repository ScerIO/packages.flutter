import 'dart:async';

import 'package:explorer/src/data/models/state.dart';
import 'package:explorer/src/explorer.dart';
import 'package:explorer/src/i18n/localization.dart';
import 'package:explorer/src/ui/provider.dart';
import 'package:flutter/material.dart';

/// Available actions view for explorer builder
class ExplorerActionView extends StatefulWidget {
  const ExplorerActionView({Key? key}) : super(key: key);

  @override
  State<ExplorerActionView> createState() => _ExplorerActionViewState();
}

class _ExplorerActionViewState extends State<ExplorerActionView>
    with SingleTickerProviderStateMixin {
  late ExplorerController _controller;
  late AnimationController _animationController;
  StreamSubscription<ExplorerAction>? _subscription;

  @override
  void initState() {
    _controller = ControllerProvider.of(context)!.explorerController;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _subscription = _controller.actionStream.listen((state) {
      if (state is ExplorerActionEmpty) {
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
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = ExplorerLocalizations.of(context);

    return StreamBuilder<ExplorerAction>(
      initialData: ExplorerActionEmpty(),
      stream: _controller.actionStream,
      builder: (_, snapshot) {
        Widget content = const SizedBox();
        if (snapshot.data is ExplorerActionCopy ||
            snapshot.data is ExplorerActionMove) {
          content = Container(
            height: 48,
            color: theme.cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (snapshot.data is ExplorerActionCopy)
                  TextButton(
                    child: Text(i18n!.actionCopyHere),
                    onPressed: () {
                      _controller.copyEntriesConfirm(
                        (snapshot.data as ExplorerActionCopy).from!,
                      );
                    },
                  ),
                if (snapshot.data is ExplorerActionMove)
                  TextButton(
                    child: Text(i18n!.actionMoveHere),
                    onPressed: () {
                      _controller.moveEntriesConfirm(
                        (snapshot.data as ExplorerActionMove).from!,
                      );
                    },
                  ),
                const SizedBox(width: 16),
                const VerticalDivider(indent: 8, endIndent: 8),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _controller.cancelAction,
                  child: Text(i18n!.cancel),
                ),
              ],
            ),
          );
        }

        return SliverToBoxAdapter(
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, -1),
              end: const Offset(0, 0),
            ).animate(_animationController),
            child: content,
          ),
        );
      },
    );
  }
}
