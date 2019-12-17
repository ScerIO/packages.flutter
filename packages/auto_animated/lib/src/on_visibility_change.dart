import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

typedef AutoAnimatedBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
);

class AnimateOnVisibilityChange extends StatefulWidget {
  const AnimateOnVisibilityChange({
    @required Key key,
    @required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
  }) : super(key: key);

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
        if (!mounted) {
          return;
        }
        if (_wrapper != null) {
          _wrapper.stack.add(() {
            _controller.forward();
          });
        } else {
          _controller.forward();
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
    this.showItemInterval = const Duration(milliseconds: 150),
    Key key,
  }) : super(key: key);

  final Widget child;
  final Duration showItemInterval;

  @override
  _AnimateOnVisibilityWrapperState createState() =>
      _AnimateOnVisibilityWrapperState();
}

class _AnimateOnVisibilityWrapperState
    extends State<AnimateOnVisibilityWrapper> {
  _VisibilityStack _stack;
  double _lastScrollExtend = 0;

  @override
  void initState() {
    _stack = _VisibilityStack(widget.showItemInterval);
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

  final _VisibilityStack stack;

  static _VisibilityStackProvider of(BuildContext context) => context
      .ancestorInheritedElementForWidgetOfExactType(_VisibilityStackProvider)
      ?.widget;

  @override
  bool updateShouldNotify(_VisibilityStackProvider oldWidget) =>
      oldWidget.stack != stack;
}

class _VisibilityStack {
  _VisibilityStack(this.showItemInterval);

  Duration showItemInterval;
  AnimationDirection direction = AnimationDirection.toEnd;
  bool _isAnimated = false;

  final List<Function> _stack = [];

  void add(VoidCallback callback) {
    _stack.add(callback);
    _animate();
  }

  void _show() {
    if (direction == AnimationDirection.toEnd) {
      _stack
        ..first.call()
        ..removeAt(0);
    } else {
      _stack
        ..last.call()
        ..removeLast();
    }
  }

  void _animate() {
    if (_isAnimated) {
      return;
    }
    _isAnimated = true;

    Future.delayed(showItemInterval, () {
      if (_stack.isNotEmpty) {
        _show();
        _isAnimated = false;
        _animate();
      } else {
        _isAnimated = false;
      }
    });
  }

  void dispose() {}

  @override
  bool operator ==(Object o) =>
      o is _VisibilityStack && showItemInterval == o.showItemInterval;

  @override
  int get hashCode => showItemInterval.hashCode;
}

enum AnimationDirection {
  toStart,
  toEnd,
}
