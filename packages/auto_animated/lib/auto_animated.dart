import 'dart:async';

import 'package:flutter/widgets.dart';

class AutoAnimatedList extends StatefulWidget {
  const AutoAnimatedList({
    @required this.itemBuilder,
    @required this.itemsCount,
    this.delay = Duration.zero,
    this.showItemInterval = const Duration(milliseconds: 250),
    this.showItemDuration = const Duration(milliseconds: 250),
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.listKey,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    Key key,
  }) : super(key: key);

  final int itemsCount;
  final Axis scrollDirection;
  final EdgeInsets padding;
  final Duration delay, showItemInterval, showItemDuration;
  final AnimatedListItemBuilder itemBuilder;
  final GlobalKey<AnimatedListState> listKey;
  final ScrollController controller;
  final bool reverse, primary, shrinkWrap;
  final ScrollPhysics physics;

  @override
  _AutoAnimatedListState createState() => _AutoAnimatedListState();
}

class _AutoAnimatedListState extends State<AutoAnimatedList> {
  GlobalKey<AnimatedListState> _listKey;
  int _itemsLength = 0;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _listKey = widget.listKey ?? GlobalKey<AnimatedListState>();
    Future.delayed(widget.delay, () {
      _timer = Timer.periodic(widget.showItemInterval, (Timer t) {
        if (_itemsLength == widget.itemsCount || !mounted) {
          return t.cancel();
        }
        setState(() {
          _listKey.currentState?.insertItem(
            _itemsLength,
            duration: widget.showItemDuration,
          );
          _itemsLength++;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedList(
        key: _listKey,
        itemBuilder: widget.itemBuilder,
        initialItemCount: _itemsLength,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        primary: widget.primary,
        physics: widget.physics,
        padding: widget.padding,
      );

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
