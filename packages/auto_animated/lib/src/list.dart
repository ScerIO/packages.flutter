// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'animate_if_visible.dart';
import 'helpers/callbacks.dart';
import 'helpers/options.dart';
import 'helpers/utils.dart' as utils;

const Duration _kDuration = Duration(milliseconds: 150);

/// A scrolling container that animates items
/// when widget mounted or they are inserted or removed.
class LiveList extends StatefulWidget {
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
  /// or equal to zero and less than `itemCount - 1`. May be null
  ///
  /// The `itemBuilder` and `separatorBuilder` callbacks should actually create
  /// widget instances when called. Avoid using a builder that returns a
  /// previously-constructed widget; if the list view's children are created in
  /// advance, or all at once when the
  /// [LiveList] itself is created, it is more
  /// efficient to use [new LiveList].
  ///
  /// {@tool sample}
  ///
  /// This example
  ///
  /// ```dart
  /// LiveList(
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
  const LiveList({
    required this.itemBuilder,
    required this.itemCount,
    this.separatorBuilder,
    this.visibleFraction = 0.025,
    this.reAnimateOnVisibility = false,
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
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    Key? key,
  })  : assert(itemCount >= 0),
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
  /// or equal to zero and less than `itemCount - 1`. May be null
  ///
  /// The `itemBuilder` and `separatorBuilder` callbacks should actually create
  /// widget instances when called. Avoid using a builder that returns a
  /// previously-constructed widget; if the list view's children are created in
  /// advance, or all at once when the
  /// [LiveList] itself is created, it is more
  /// efficient to use [new LiveList].
  ///
  /// {@tool sample}
  ///
  /// This example
  ///
  /// ```dart
  /// LiveList.options(
  ///   itemCount: 25,
  ///   option: LiveOptions(
  ///     // Start animation after (default zero)
  ///     delay: Duration(seconds: 1),
  ///     // Show each item through
  ///     showItemInterval: Duration(milliseconds: 500),
  ///     // Animation duration
  ///     showItemDuration: Duration(seconds: 1),
  ///     // Animations starts at 0.025 visible item fraction in sight
  ///     visibleFraction: 0.025,
  ///   ),
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
  LiveList.options({
    required this.itemBuilder,
    required this.itemCount,
    required LiveOptions options,
    this.separatorBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
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

  /// Called, as needed, to build list item widgets.
  final LiveListItemBuilder itemBuilder;

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
  final IndexedWidgetBuilder? separatorBuilder;

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
  final ScrollController? controller;

  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// On iOS, this identifies the scroll view that will scroll to top in
  /// response to a tap in the status bar.
  ///
  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [controller] is null.
  final bool? primary;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

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
  final EdgeInsetsGeometry? padding;

  final bool addAutomaticKeepAlives;

  final bool addRepaintBoundaries;

  final bool addSemanticIndexes;

  @override
  LiveListState createState() => LiveListState();
}

/// The state for a scrolling container that animates items when they are
/// inserted or removed.
///
/// An app that needs to insert or remove items in response to an event
/// can refer to the [LiveList]'s state with a global key:
///
/// ```dart
/// GlobalKey<LiveListState> listKey =
///    GlobalKey<LiveListState>();
/// ...
/// LiveList(key: listKey, ...);
/// ...
/// listKey.currentState.insert(123);
/// ```
class LiveListState extends State<LiveList>
    with TickerProviderStateMixin<LiveList> {
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
  Widget build(BuildContext context) {
    SliverChildBuilderDelegate childDelegate;
    if (widget.separatorBuilder != null) {
      childDelegate = SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final int itemIndex = index ~/ 2;
          Widget? widget;
          if (index.isEven) {
            widget = _itemBuilder(context, itemIndex);
          } else {
            widget = this.widget.separatorBuilder!(context, itemIndex);
            assert(() {
              if (widget == null) {
                throw FlutterError('separatorBuilder cannot return null.');
              }
              return true;
            }());
          }
          return widget;
        },
        childCount: _computeSemanticChildCount(widget.itemCount),
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        semanticIndexCallback: (Widget _, int index) =>
            index.isEven ? index ~/ 2 : null,
      );
    } else {
      childDelegate = SliverChildBuilderDelegate(
        _itemBuilder,
        childCount: widget.itemCount,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
      );
    }

    return AnimateIfVisibleWrapper(
      delay: widget.delay,
      showItemInterval: widget.showItemInterval,
      child: ListView.custom(
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        childrenDelegate: childDelegate,
      ),
    );
  }

  // Helper method to compute the semantic
  // child count for the separated constructor.
  static int _computeSemanticChildCount(int itemCount) =>
      math.max(0, itemCount * 2 - 1);
}
