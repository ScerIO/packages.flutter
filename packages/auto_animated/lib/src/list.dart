// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'helpers/callbacks.dart';
import 'helpers/utils.dart' as utils;
import 'on_visibility_change.dart';

const Duration _kDuration = Duration(milliseconds: 150);

/// A scrolling container that animates items
/// when widget mounted or they are inserted or removed.
class AutoAnimatedList extends StatefulWidget {
  /// Creates a scrolling container that animates items
  ///  when they are inserted or removed.
  const AutoAnimatedList({
    @required this.itemBuilder,
    @required this.itemCount,
    this.hideWhenGoingBeyond = true,
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
    @required this.itemBuilder,
    @required this.separatorBuilder,
    @required this.itemCount,
    this.hideWhenGoingBeyond = true,
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
  })  : assert(itemBuilder != null && separatorBuilder != null),
        assert(itemCount != null && itemCount >= 0),
        super(key: key);

  /// Start animation after (default zero)
  final Duration delay;

  /// Show each item through
  final Duration showItemInterval;

  /// Animation duration
  final Duration showItemDuration;

  /// Hide the element when it approaches the
  /// frame of the screen so that in the future,
  /// when it falls into the visibility
  ///  range, the animation can be played again.
  ///
  /// The appearance animation will also play when the item
  /// is redrawn. Redrawing is peculiar for all
  ///  list \ grid views with builder methods
  final bool hideWhenGoingBeyond;

  /// Called, as needed, to build list item widgets.
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

  @override
  AutoAnimatedListState createState() => AutoAnimatedListState();
}

/// The state for a scrolling container that animates items when they are
/// inserted or removed.
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
class AutoAnimatedListState extends State<AutoAnimatedList>
    with TickerProviderStateMixin<AutoAnimatedList> {
  final String _keyPrefix = utils.createCryptoRandomString();

  Widget _itemBuilder(BuildContext context, int itemIndex) =>
      AnimateOnVisibilityChange(
        key: Key('$_keyPrefix.$itemIndex'),
        duration: widget.showItemDuration,
        hideWhenGoingBeyond: widget.hideWhenGoingBeyond,
        builder: (context, animation) => widget.itemBuilder(
          context,
          itemIndex,
          animation,
        ),
      );

  @override
  Widget build(BuildContext context) {
    Widget list;
    if (widget.separatorBuilder != null) {
      list = ListView.separated(
        itemBuilder: _itemBuilder,
        separatorBuilder: widget.separatorBuilder,
        itemCount: widget.itemCount,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
      );
    } else {
      list = ListView.builder(
        itemBuilder: _itemBuilder,
        itemCount: widget.itemCount,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
      );
    }

    return AnimateOnVisibilityWrapper(
      delay: widget.delay,
      showItemInterval: widget.showItemInterval,
      useListStack: true,
      child: list,
    );
  }
}
