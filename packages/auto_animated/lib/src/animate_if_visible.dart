import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'animator/stack.dart';

const double defaultVisibilityFraction = 0.025;

typedef AutoAnimatedBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
);

class AnimateIfVisible extends StatefulWidget {
  const AnimateIfVisible({
    required Key key,
    required this.builder,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 250),
    this.reAnimateOnVisibility = false,
    this.visibleFraction = 0.025,
  })  : assert(visibleFraction > 0 && visibleFraction < 1),
        super(key: key);

  final AutoAnimatedBuilder builder;
  final Duration duration, delay;

  /// A fraction in the range \[0, 1\] that represents what proportion of the
  /// widget is visible (assuming rectangular bounding boxes).
  ///
  /// 0 means not visible; 1 means fully visible.
  final double visibleFraction;

  /// Hide the element when it approaches the
  /// frame of the screen so that in the future,
  /// when it falls into the visibility range - reproduce animation again
  final bool reAnimateOnVisibility;

  @override
  _AnimateIfVisibleState createState() => _AnimateIfVisibleState();
}

class _AnimateIfVisibleState extends State<AnimateIfVisible>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  _VisibilityStackProvider? _wrapper;

  @override
  void initState() {
    _wrapper = _VisibilityStackProvider.of(context);
    final itemAlreadyShowed = _wrapper!.stack!.isAlreadyAnimated(widget.key) &&
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
        key: widget.key!,
        child: widget.builder(
          context,
          _controller.view,
        ),
        onVisibilityChanged: _visibilityChanged,
      );

  void _visibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > widget.visibleFraction &&
        !_controller.isCompleted) {
      Future.delayed(widget.delay, () {
        if (_wrapper != null) {
          _wrapper!.stack!.add(widget.key, () {
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
    } else if (info.visibleFraction <= widget.visibleFraction &&
        mounted &&
        widget.reAnimateOnVisibility &&
        !info.visibleBounds.isEmpty) {
      _controller.reverse();
    } else if (info.visibleFraction <= widget.visibleFraction &&
        mounted &&
        widget.reAnimateOnVisibility &&
        info.visibleBounds.isEmpty) {
      _controller.reset();
    }
  }
}

class AnimateIfVisibleWrapper extends StatefulWidget {
  const AnimateIfVisibleWrapper({
    required this.child,
    this.delay = Duration.zero,
    this.showItemInterval = const Duration(milliseconds: 150),
    this.controller,
    Key? key,
  }) : super(key: key);

  final ScrollController? controller;
  final Widget child;
  final Duration delay, showItemInterval;

  @override
  _AnimateIfVisibleWrapperState createState() =>
      _AnimateIfVisibleWrapperState();
}

class _AnimateIfVisibleWrapperState extends State<AnimateIfVisibleWrapper> {
  VisibilityStack? _stack;
  double _lastScrollExtend = 0;

  @override
  void initState() {
    _stack = VisibilityStack(
      delay: widget.delay,
      showItemInterval: widget.showItemInterval,
    );
    if (widget.controller != null && widget.controller!.hasClients) {
      widget.controller!.addListener(_handleScrollController);
    }
    super.initState();
  }

  @override
  void dispose() {
    _stack!.dispose();
    widget.controller?.removeListener(_handleScrollController);
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimateIfVisibleWrapper oldWidget) {
    if (oldWidget.showItemInterval != widget.showItemInterval) {
      _stack!.showItemInterval = widget.showItemInterval;
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
    _setDirection(
      widget.controller!.offset,
      widget.controller!.position.minScrollExtent,
      widget.controller!.position.maxScrollExtent,
    );
  }

  bool _handleScrollNotifications(ScrollNotification scrollInfo) {
    _setDirection(
      scrollInfo.metrics.pixels,
      scrollInfo.metrics.minScrollExtent,
      scrollInfo.metrics.maxScrollExtent,
    );
    return true;
  }

  void _setDirection(
    double offset,
    double minScrollExtent,
    double maxScrollExtent,
  ) {
    if (offset < minScrollExtent || offset > maxScrollExtent) {
      return;
    }
    if (offset > _lastScrollExtend + 2.5) {
      // to end
      _stack!.direction = AnimationDirection.toEnd;
    } else if (offset < _lastScrollExtend - 2.5) {
      // to start
      _stack!.direction = AnimationDirection.toStart;
    }
    _lastScrollExtend = offset;
  }
}

class _VisibilityStackProvider extends InheritedWidget {
  _VisibilityStackProvider({
    required Widget child,
    required this.stack,
    Key? key,
  }) : super(key: key, child: child);

  final VisibilityStack? stack;

  static _VisibilityStackProvider? of(BuildContext context) => context
      .getElementForInheritedWidgetOfExactType<_VisibilityStackProvider>()
      ?.widget as _VisibilityStackProvider?;

  @override
  bool updateShouldNotify(_VisibilityStackProvider oldWidget) =>
      oldWidget.stack != stack;
}
