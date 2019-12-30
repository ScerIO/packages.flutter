import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

import 'animator/stack.dart';

typedef AutoAnimatedBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
);

class AnimateOnVisibilityChange extends StatefulWidget {
  const AnimateOnVisibilityChange({
    @required Key key,
    @required this.builder,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 250),
    this.reAnimateOnVisibility = false,
  })  : assert(delay != null),
        assert(duration != null),
        super(key: key);

  final AutoAnimatedBuilder builder;
  final Duration duration, delay;

  /// Hide the element when it approaches the
  /// frame of the screen so that in the future,
  /// when it falls into the visibility range - reproduce animation again
  final bool reAnimateOnVisibility;

  @override
  _AnimateOnVisibilityChangeState createState() =>
      _AnimateOnVisibilityChangeState();
}

class _AnimateOnVisibilityChangeState extends State<AnimateOnVisibilityChange>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  _VisibilityStackProvider _wrapper;

  @override
  void initState() {
    _wrapper = _VisibilityStackProvider.of(context);
    final itemAlreadyShowed = _wrapper.stack.isAlreadyAnimated(widget.key) &&
        !widget.reAnimateOnVisibility;

    _controller = AnimationController(
      value: itemAlreadyShowed ? 1 : 0,
      duration: widget.duration,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
        key: widget.key,
        child: widget.builder(
          context,
          _controller.view,
        ),
        onVisibilityChanged: _visibilityChanged,
      );

  void _visibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0.025 && !_controller.isCompleted) {
      Future.delayed(widget.delay, () {
        if (_wrapper != null) {
          _wrapper.stack.add(widget.key, () {
            if (mounted) {
              _controller.forward();
            }
          });
        } else {
          if (mounted) {
            _controller.forward();
          }
        }
      });
    } else if (info.visibleFraction <= 0.025 &&
        mounted &&
        widget.reAnimateOnVisibility &&
        !info.visibleBounds.isEmpty) {
      _controller.reverse();
    }
  }
}

class AnimateOnVisibilityWrapper extends StatefulWidget {
  const AnimateOnVisibilityWrapper({
    @required this.child,
    this.delay = Duration.zero,
    this.showItemInterval = const Duration(milliseconds: 150),
    this.controller,
    Key key,
  })  : assert(delay != null),
        assert(showItemInterval != null),
        super(key: key);

  final ScrollController controller;
  final Widget child;
  final Duration delay, showItemInterval;

  @override
  _AnimateOnVisibilityWrapperState createState() =>
      _AnimateOnVisibilityWrapperState();
}

class _AnimateOnVisibilityWrapperState
    extends State<AnimateOnVisibilityWrapper> {
  VisibilityStack _stack;
  double _lastScrollExtend = 0;

  @override
  void initState() {
    _stack = VisibilityStack(
      delay: widget.delay,
      showItemInterval: widget.showItemInterval,
    );
    if (widget.controller != null && widget.controller.hasClients) {
      widget.controller.addListener(_handleScrollController);
    }
    super.initState();
  }

  @override
  void dispose() {
    _stack.dispose();
    widget.controller?.removeListener(_handleScrollController);
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimateOnVisibilityWrapper oldWidget) {
    if (oldWidget.showItemInterval != widget.showItemInterval) {
      _stack.showItemInterval = widget.showItemInterval;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) => _VisibilityStackProvider(
        stack: _stack,
        child: NotificationListener<ScrollNotification>(
          child: widget.child,
          onNotification: _handleScrollNotifications,
        ),
      );

  void _handleScrollController() {
    _setDirection(widget.controller.offset);
  }

  bool _handleScrollNotifications(ScrollNotification scrollInfo) {
    _setDirection(scrollInfo.metrics.pixels);
    return true;
  }

  void _setDirection(double offset) {
    if (offset > _lastScrollExtend + 2.5) {
      // to end
      _stack.direction = AnimationDirection.toEnd;
    } else if (offset < _lastScrollExtend - 2.5) {
      // to start
      _stack.direction = AnimationDirection.toStart;
    }
    _lastScrollExtend = offset;
  }
}

class _VisibilityStackProvider extends InheritedWidget {
  _VisibilityStackProvider({
    @required Widget child,
    @required this.stack,
    Key key,
  })  : assert(child != null),
        super(key: key, child: child);

  final VisibilityStack stack;

  static _VisibilityStackProvider of(BuildContext context) => context
      .getElementForInheritedWidgetOfExactType<_VisibilityStackProvider>()
      ?.widget;

  @override
  bool updateShouldNotify(_VisibilityStackProvider oldWidget) =>
      oldWidget.stack != stack;
}
