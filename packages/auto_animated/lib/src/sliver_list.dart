import 'package:flutter/material.dart';

import 'animate_if_visible.dart';
import 'helpers/callbacks.dart';
import 'helpers/options.dart';
import 'helpers/utils.dart' as utils;

const Duration _kDuration = Duration(milliseconds: 250);

class LiveSliverList extends StatefulWidget {
  const LiveSliverList({
    required this.itemBuilder,
    required this.itemCount,
    required this.controller,
    this.visibleFraction = 0.025,
    this.reAnimateOnVisibility = false,
    this.delay = Duration.zero,
    this.showItemInterval = _kDuration,
    this.showItemDuration = _kDuration,
    Key? key,
  })  : assert(itemCount >= 0),
        super(key: key);

  LiveSliverList.options({
    required this.itemBuilder,
    required this.itemCount,
    required this.controller,
    required LiveOptions options,
    Key? key,
  })  : delay = options.delay,
        showItemInterval = options.showItemInterval,
        showItemDuration = options.showItemDuration,
        visibleFraction = options.visibleFraction,
        reAnimateOnVisibility = options.reAnimateOnVisibility,
        assert(itemCount >= 0),
        super(key: key);

  /// Start animation after (default zero)
  final Duration delay;

  /// Show each item through
  final Duration showItemInterval;

  /// Animation duration
  final Duration showItemDuration;

  /// A fraction in the range \[0, 1\] that represents what proportion of the
  /// widget is visible (assuming rectangular bounding boxes).
  ///
  /// 0 means not visible; 1 means fully visible.
  final double visibleFraction;

  /// Hide the element when it approaches the
  /// frame of the screen so that in the future,
  /// when it falls into the visibility range - reproduce animation again
  final bool reAnimateOnVisibility;

  /// It is necessary in order to
  /// find out in which direction the
  /// widget scrolls in order to play
  ///  the animation in the corresponding direction
  final ScrollController controller;

  /// Called, as needed, to build list item widgets.
  final LiveListItemBuilder itemBuilder;

  /// The number of items the list will start with.
  ///
  /// The appearance of the initial items is not animated. They
  /// are created, as needed, by [itemBuilder] with an animation parameter
  /// of [kAlwaysCompleteAnimation].
  final int itemCount;

  @override
  _LiveSliverListState createState() => _LiveSliverListState();
}

class _LiveSliverListState extends State<LiveSliverList>
    with TickerProviderStateMixin<LiveSliverList> {
  final String _keyPrefix = utils.createCryptoRandomString();

  Widget _itemBuilder(BuildContext context, int itemIndex) => AnimateIfVisible(
        key: Key('$_keyPrefix.$itemIndex'),
        duration: widget.showItemDuration,
        visibleFraction: widget.visibleFraction,
        reAnimateOnVisibility: widget.reAnimateOnVisibility,
        builder: (context, animation) => widget.itemBuilder(
          context,
          itemIndex,
          animation,
        ),
      );

  @override
  Widget build(BuildContext context) => AnimateIfVisibleWrapper(
        controller: widget.controller,
        delay: widget.delay,
        showItemInterval: widget.showItemInterval,
        child: SliverList(
          delegate: SliverChildBuilderDelegate(
            _itemBuilder,
            childCount: widget.itemCount,
          ),
        ),
      );
}
