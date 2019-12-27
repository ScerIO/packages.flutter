import 'package:auto_animated/src/on_visibility_change.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'helpers/callbacks.dart';
import 'helpers/utils.dart' as utils;

const Duration _kDuration = Duration(milliseconds: 300);

class AutoAnimatedSliverGrid extends StatefulWidget {
  const AutoAnimatedSliverGrid({
    @required this.itemBuilder,
    @required this.gridDelegate,
    @required this.itemCount,
    this.hideWhenGoingBeyond = true,
    this.delay = Duration.zero,
    this.reverse = false,
    this.showItemInterval = _kDuration,
    this.showItemDuration = _kDuration,
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
  /// when it falls into the visibility
  ///  range, the animation can be played again.
  ///
  /// The appearance animation will also play when the item
  /// is redrawn. Redrawing is peculiar for all
  ///  list \ grid views with builder methods
  final bool hideWhenGoingBeyond;

  /// Called, as needed, to build list item widgets.
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
    with TickerProviderStateMixin<AutoAnimatedSliverGrid> {
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
  Widget build(BuildContext context) => AnimateOnVisibilityWrapper(
        delay: widget.delay,
        showItemInterval: widget.showItemInterval,
        useListStack: true,
        child: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            _itemBuilder,
            childCount: widget.itemCount,
          ),
          gridDelegate: widget.gridDelegate,
        ),
      );
}
