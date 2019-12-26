import 'package:auto_animated/src/on_visibility_change.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'helpers/callbacks.dart';
import 'helpers/utils.dart' as utils;

const Duration _kDuration = Duration(milliseconds: 300);

class AutoAnimatedSliverList extends StatefulWidget {
  const AutoAnimatedSliverList({
    @required this.itemBuilder,
    @required this.itemCount,
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
        duration: widget.showItemDuration,
        key: Key('$_keyPrefix.$itemIndex'),
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
        child: SliverList(
          delegate: SliverChildBuilderDelegate(
            _itemBuilder,
            childCount: widget.itemCount,
          ),
        ),
      );
}
