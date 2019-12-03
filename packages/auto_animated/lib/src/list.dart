// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'list_animation.dart';

const Duration _kDuration = Duration(milliseconds: 300);

/// A scrolling container that animates items
/// when widget mounted or they are inserted or removed.
///
/// This widget's [AutoAnimatedListState] can
///  be used to dynamically insert or remove
/// items. To refer to the [AutoAnimatedListState]
/// either provide a [GlobalKey] or
/// use the static [of] method from an item's input callback.
///
/// This widget is similar to one created by [ListView.builder].
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=ZtfItHwFlZ8}
class AutoAnimatedList extends StatefulWidget {
  /// Creates a scrolling container that animates items
  ///  when they are inserted or removed.
  const AutoAnimatedList({
    @required this.itemBuilder,
    @required this.itemCount,
    this.delay = Duration.zero,
    this.showItemInterval = _kDuration,
    this.showItemDuration = _kDuration,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    Key key,
  })  : assert(itemBuilder != null),
        assert(itemCount != null && itemCount >= 0),
        separatorBuilder = null,
        super(key: key);

  /// Creates a fixed-length scrollable linear array of list "items" separated
  /// by list item "separators".
  ///
  /// This constructor is appropriate for list views with a large number of
  /// item and separator children because the builders are only called for
  /// the children that are actually visible.
  ///
  /// The `itemBuilder` callback will be called with indices greater than
  /// or equal to zero and less than `itemCount`.
  ///
  /// Separators only appear between list items: separator 0 appears after item
  /// 0 and the last separator appears before the last item.
  ///
  /// The `separatorBuilder` callback will be called with indices greater than
  /// or equal to zero and less than `itemCount - 1`.
  ///
  /// The `itemBuilder` and `separatorBuilder` callbacks should actually create
  /// widget instances when called. Avoid using a builder that returns a
  /// previously-constructed widget; if the list view's children are created in
  /// advance, or all at once when the
  /// [AutoAnimatedList] itself is created, it is more
  /// efficient to use [new AutoAnimatedList].
  ///
  /// {@tool sample}
  ///
  /// This example
  ///
  /// ```dart
  /// AutoAnimatedList.separated(
  ///   itemCount: 25,
  ///   separatorBuilder: (BuildContext context, int index) => Divider(),
  ///   itemBuilder: (_ context, int index, Animation<double> animation) {
  ///     return ListTile(
  ///       title: Text('item $index'),
  ///     );
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildBuilderDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildBuilderDelegate.addRepaintBoundaries] property. The
  /// `addSemanticIndexes` argument corresponds to the
  /// [SliverChildBuilderDelegate.addSemanticIndexes] property. None may be
  /// null.
  const AutoAnimatedList.separated({
    @required
        this.itemBuilder,
    @required
        this.separatorBuilder,
    Key key,
    this.delay = Duration.zero,
    this.showItemInterval = _kDuration,
    this.showItemDuration = _kDuration,
    @Deprecated('Usage `itemCount` instead '
        '(without character "s"). Will be deleted in 1.2.0')
        int itemsCount = 0,
    int itemCount = 0,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
  })  : assert(itemBuilder != null && separatorBuilder != null),
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

  /// Signature for a function that creates a widget for
  ///  a given index, e.g., in a
  /// list.
  ///
  /// Used by [ListView.builder] and other APIs that use
  /// lazily-generated widgets.
  ///
  /// See also:
  ///
  ///  * [WidgetBuilder], which is similar but only takes a [BuildContext].
  ///  * [TransitionBuilder], which is similar but also takes a child.
  final IndexedWidgetBuilder separatorBuilder;

  /// The number of items the list will start with.
  ///
  /// The appearance of the initial items is not animated. They
  /// are created, as needed, by [itemBuilder] with an animation parameter
  /// of [kAlwaysCompleteAnimation].
  final int itemCount;

  /// The axis along which the scroll view scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

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

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  ///
  /// Must be null if [primary] is true.
  ///
  /// A [ScrollController] serves several purposes. It can be used to control
  /// the initial scroll position (see [ScrollController.initialScrollOffset]).
  /// It can be used to control whether the scroll view should automatically
  /// save and restore its scroll position in the [PageStorage] (see
  /// [ScrollController.keepScrollOffset]). It can be used to read the current
  /// scroll position (see [ScrollController.offset]), or change it (see
  /// [ScrollController.animateTo]).
  final ScrollController controller;

  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// On iOS, this identifies the scroll view that will scroll to top in
  /// response to a tap in the status bar.
  ///
  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [controller] is null.
  final bool primary;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics physics;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// If the scroll view does not shrink wrap, then the scroll view will expand
  /// to the maximum allowed size in the [scrollDirection]. If the scroll view
  /// has unbounded constraints in the [scrollDirection], then [shrinkWrap] must
  /// be true.
  ///
  /// Shrink wrapping the content of the scroll view is significantly more
  /// expensive than expanding to the maximum allowed size because the content
  /// can expand and contract during scrolling, which means the size of the
  /// scroll view needs to be recomputed whenever the scroll position changes.
  ///
  /// Defaults to false.
  final bool shrinkWrap;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry padding;

  /// The state from the closest instance of
  /// this class that encloses the given context.
  ///
  /// This method is typically used by
  /// [AutoAnimatedList] item widgets that insert or
  /// remove items in response to user input.
  ///
  /// ```dart
  /// AutoAnimatedListState AutoAnimatedList = AutoAnimatedList.of(context);
  /// ```
  static AutoAnimatedListState of(BuildContext context, {bool nullOk = false}) {
    assert(context != null);
    assert(nullOk != null);
    final AutoAnimatedListState result =
        context.ancestorStateOfType(const TypeMatcher<AutoAnimatedListState>());
    if (nullOk || result != null) {
      return result;
    }
    throw FlutterError('AutoAnimatedList.of() called with a context '
        'that does not contain an AutoAnimatedList.\n'
        'No AutoAnimatedList ancestor could be found '
        'starting from the context that was passed to AutoAnimatedList.of(). '
        'This can happen when the context provided '
        'is from the same StatefulWidget that '
        'built the AutoAnimatedList. Please see the '
        'AutoAnimatedList documentation for examples '
        'of how to refer to an AutoAnimatedListState object: '
        '  https://api.flutter.dev/flutter/widgets/AutoAnimatedListState-class.html \n'
        'The context used was:\n'
        '  $context');
  }

  @override
  AutoAnimatedListState createState() => AutoAnimatedListState();
}

/// The state for a scrolling container that animates items when they are
/// inserted or removed.
///
/// When an item is inserted with [insertItem] an animation begins running. The
/// animation is passed to [AutoAnimatedList.itemBuilder]
/// whenever the item's widget is needed.
///
/// When an item is removed with [removeItem] its animation is reversed.
/// The removed item's animation is passed to the [removeItem] builder
/// parameter.
///
/// An app that needs to insert or remove items in response to an event
/// can refer to the [AutoAnimatedList]'s state with a global key:
///
/// ```dart
/// GlobalKey<AutoAnimatedListState> listKey =
///    GlobalKey<AutoAnimatedListState>();
/// ...
/// AutoAnimatedList(key: listKey, ...);
/// ...
/// listKey.currentState.insert(123);
/// ```
///
/// [AutoAnimatedList] item input handlers can
/// also refer to their [AutoAnimatedListState]
/// with the static [AutoAnimatedList.of] method.
class AutoAnimatedListState extends State<AutoAnimatedList>
    with
        TickerProviderStateMixin<AutoAnimatedList>,
        ListAnimation<AutoAnimatedList> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init({int from = 0}) {
    itemsCount = from;
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
  void didUpdateWidget(AutoAnimatedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemCount < oldWidget.itemCount) {
      init();
    } else if (itemsCount < widget.itemCount && !(_timer?.isActive ?? true)) {
      init(from: itemsCount);
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
  Widget build(BuildContext context) {
    if (widget.separatorBuilder != null) {
      return ListView.separated(
        itemBuilder: _itemBuilder,
        separatorBuilder: widget.separatorBuilder,
        itemCount: itemsCount,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
      );
    }

    return ListView.builder(
      itemBuilder: _itemBuilder,
      itemCount: itemsCount,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
    );
  }

  @override
  TickerProvider get vsync => this;
}
