import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'list_animation.dart';

const Duration _kDuration = Duration(milliseconds: 300);

class AutoAnimatedSliverGrid extends StatefulWidget {
  ///  when they are inserted or removed.
  const AutoAnimatedSliverGrid({
    @required
        this.itemBuilder,
    @required
        this.gridDelegate,
    Key key,
    this.delay = Duration.zero,
    this.reverse = false,
    this.showItemInterval = _kDuration,
    this.showItemDuration = _kDuration,
    @Deprecated('Usage `itemCount` instead '
        '(without character "s"). Will be deleted in 1.2.0')
        int itemsCount = 0,
    int itemCount = 0,
  })  : assert(itemBuilder != null),
        // ignore: deprecated_member_use_from_same_package
        itemCount = itemCount ?? itemsCount,
        assert(itemCount != null && itemCount >= 0),
        super(key: key);

  /// Start animation after (default zero)
  final Duration delay;

  /// Show each item through
  final Duration showItemInterval;

  /// Animation duration
  final Duration showItemDuration;

  /// Called, as needed, to build list item widgets.
  ///
  /// List items are only built when they're scrolled into view.
  /// Implementations of this callback should assume that
  /// [AutoAnimatedListState.removeItem] removes an item immediately.
  final AutoAnimatedListItemBuilder itemBuilder;

  /// The number of items the list will start with.
  ///
  /// The appearance of the initial items is not animated. They
  /// are created, as needed, by [itemBuilder] with an animation parameter
  /// of [kAlwaysCompleteAnimation].
  final int itemCount;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// A delegate that controls the layout of the children within the [GridView].
  ///
  /// The [GridView], [GridView.builder], and [GridView.custom]
  /// constructors let you specify this
  /// delegate explicitly. The other constructors create a [gridDelegate]
  /// implicitly.
  final SliverGridDelegate gridDelegate;

  @override
  _AutoAnimatedSliverGridState createState() => _AutoAnimatedSliverGridState();
}

class _AutoAnimatedSliverGridState extends State<AutoAnimatedSliverGrid>
    with
        TickerProviderStateMixin<AutoAnimatedSliverGrid>,
        ListAnimation<AutoAnimatedSliverGrid> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    itemsCount = 0;
    Future.delayed(widget.delay, () {
      _timer = Timer.periodic(widget.showItemInterval, (Timer timer) {
        if (itemsCount == widget.itemCount || !mounted) {
          return timer.cancel();
        }
        insertItem(
          widget.reverse ? 0 : itemsCount,
          duration: widget.showItemDuration,
        );
      });
    });
  }

  @override
  void didUpdateWidget(AutoAnimatedSliverGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      init();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (ActiveItem item in incomingItems) {
      item.controller.dispose();
    }
    for (ActiveItem item in outgoingItems) {
      item.controller.dispose();
    }
    super.dispose();
  }

  Widget _itemBuilder(BuildContext context, int itemIndex) {
    final ActiveItem outgoingItem = activeItemAt(outgoingItems, itemIndex);
    if (outgoingItem != null) {
      return outgoingItem.removedItemBuilder(
          context, outgoingItem.controller.view);
    }

    final ActiveItem incomingItem = activeItemAt(incomingItems, itemIndex);
    final Animation<double> animation =
        incomingItem?.controller?.view ?? kAlwaysCompleteAnimation;
    return widget.itemBuilder(context, indexToItemIndex(itemIndex), animation);
  }

  @override
  Widget build(BuildContext context) => SliverGrid(
        delegate: SliverChildBuilderDelegate(
          _itemBuilder,
          childCount: itemsCount,
        ),
        gridDelegate: widget.gridDelegate,
      );

  @override
  TickerProvider get vsync => this;
}
