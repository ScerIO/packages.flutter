import 'package:auto_animated/src/on_visibility_change.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'helpers/callbacks.dart';
import 'helpers/utils.dart' as utils;

const Duration _kDuration = Duration(milliseconds: 250);

class AutoAnimatedSliverList extends StatefulWidget {
  const AutoAnimatedSliverList({
    @required this.itemBuilder,
    @required this.itemCount,
    @required this.controller,
    this.reAnimateOnVisibility = false,
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
  /// when it falls into the visibility range - reproduce animation again
  final bool reAnimateOnVisibility;

  /// It is necessary in order to
  /// find out in which direction the
  /// widget scrolls in order to play
  ///  the animation in the corresponding direction
  final ScrollController controller;

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
  /// Defaults to false.
  final bool reverse;

  @override
  _AutoAnimatedSliverListState createState() => _AutoAnimatedSliverListState();
}

class _AutoAnimatedSliverListState extends State<AutoAnimatedSliverList>
    with TickerProviderStateMixin<AutoAnimatedSliverList> {
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
