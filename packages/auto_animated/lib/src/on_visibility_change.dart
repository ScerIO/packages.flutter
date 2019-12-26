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
    this.duration = const Duration(milliseconds: 300),
  })  : assert(delay != null),
        assert(duration != null),
        super(key: key);

  final AutoAnimatedBuilder builder;
  final Duration duration, delay;

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
    _controller = AnimationController(
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
    if (_controller.isAnimating) {
      return;
    }
    if (info.visibleFraction > 0.025 && !_controller.isCompleted) {
      Future.delayed(widget.delay, () {
        if (_wrapper != null) {
          _wrapper.stack.add(() {
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
    } else if (info.visibleFraction <= 0.025 && mounted) {
      _controller.reverse();
    }
  }
}

class AnimateOnVisibilityWrapper extends StatefulWidget {
  const AnimateOnVisibilityWrapper({
    @required this.child,
    this.delay = Duration.zero,
    this.showItemInterval = const Duration(milliseconds: 150),
    this.useListStack = false,
    Key key,
  })  : assert(delay != null),
        assert(showItemInterval != null),
        super(key: key);

  final bool useListStack;
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
    _stack = widget.useListStack
        ? ListStack(
            delay: widget.delay,
            showItemInterval: widget.showItemInterval,
          )
        : AnimateOnVisibilityStack(
            delay: widget.delay,
            showItemInterval: widget.showItemInterval,
          );
    super.initState();
  }

  @override
  void dispose() {
    _stack.dispose();
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
          onNotification: _onScroll,
        ),
      );

  bool _onScroll(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.pixels > _lastScrollExtend + 2.5) {
      // to end
      _stack.direction = AnimationDirection.toEnd;
    } else if (scrollInfo.metrics.pixels < _lastScrollExtend - 2.5) {
      // to start
      _stack.direction = AnimationDirection.toStart;
    }
    _lastScrollExtend = scrollInfo.metrics.pixels;
    return true;
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
