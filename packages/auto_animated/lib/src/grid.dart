import 'package:auto_animated/src/on_visibility_change.dart';
import 'package:flutter/widgets.dart';

import 'helpers/callbacks.dart';
import 'helpers/utils.dart' as utils;

const Duration _kDuration = Duration(milliseconds: 250);

class AutoAnimatedGrid extends StatefulWidget {
  const AutoAnimatedGrid({
    @required this.itemBuilder,
    @required this.gridDelegate,
    @required this.itemCount,
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
    Key key,
  })  : assert(itemBuilder != null),
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
  /// when it falls into the visibility range - reproduce animation again
  final bool reAnimateOnVisibility;

  /// Called, as needed, to build list item widgets.
  ///
  /// List items are only built when they're scrolled into view.
  final AutoAnimatedListItemBuilder itemBuilder;

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

  /// A delegate that controls the layout of the children within the [GridView].
  ///
  /// The [GridView], [GridView.builder], and [GridView.custom]
  /// constructors let you specify this
  /// delegate explicitly. The other constructors create a [gridDelegate]
  /// implicitly.
  final SliverGridDelegate gridDelegate;

  /// Whether to wrap each child in an [AutomaticKeepAlive].
  ///
  /// Typically, children in lazy list are wrapped in [AutomaticKeepAlive]
  /// widgets so that children can use [KeepAliveNotification]s to preserve
  /// their state when they would otherwise be garbage collected off-screen.
  ///
  /// This feature (and [addRepaintBoundaries]) must be disabled if the children
  /// are going to manually maintain their [KeepAlive] state. It may also be
  /// more efficient to disable this feature if it is known ahead of time that
  /// none of the children will ever try to keep themselves alive.
  ///
  /// Defaults to true.
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each child in a [RepaintBoundary].
  ///
  /// Typically, children in a scrolling container are wrapped in repaint
  /// boundaries so that they do not need to be repainted as the list scrolls.
  /// If the children are easy to repaint (e.g., solid color blocks or a short
  /// snippet of text), it might be more efficient to not add a repaint boundary
  /// and simply repaint the children during scrolling.
  ///
  /// Defaults to true.
  final bool addRepaintBoundaries;

  /// Whether to wrap each child in an [IndexedSemantics].
  ///
  /// Typically, children in a scrolling container must be annotated with a
  /// semantic index in order to generate the correct accessibility
  /// announcements. This should only be set to false if the indexes have
  /// already been provided by an IndexedChildSemantics widget.
  ///
  /// Defaults to true.
  ///
  /// See also:
  ///
  ///  * IndexedChildSemantics, for an explanation of how to manually
  ///    provide semantic indexes.
  final bool addSemanticIndexes;

  @override
  _AutoAnimatedGridViewState createState() => _AutoAnimatedGridViewState();
}

class _AutoAnimatedGridViewState extends State<AutoAnimatedGrid>
    with TickerProviderStateMixin<AutoAnimatedGrid> {
  final String _keyPrefix = utils.createCryptoRandomString();

  Widget _itemBuilder(BuildContext context, int itemIndex) =>
      AnimateOnVisibilityChange(
        key: Key('$_keyPrefix.$itemIndex'),
        duration: widget.showItemDuration,
        reAnimateOnVisibility: widget.reAnimateOnVisibility,
        builder: (context, animation) => widget.itemBuilder(
          context,
          itemIndex,
          animation,
        ),
      );

  @override
  Widget build(BuildContext context) => AnimateOnVisibilityWrapper(
        delay: widget.delay,
        showItemInterval: widget.showItemInterval,
        child: GridView.builder(
          itemBuilder: _itemBuilder,
          gridDelegate: widget.gridDelegate,
          itemCount: widget.itemCount,
          scrollDirection: widget.scrollDirection,
          reverse: widget.reverse,
          controller: widget.controller,
          primary: widget.primary,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          padding: widget.padding,
          addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
          addRepaintBoundaries: widget.addRepaintBoundaries,
          addSemanticIndexes: widget.addSemanticIndexes,
        ),
      );
}
