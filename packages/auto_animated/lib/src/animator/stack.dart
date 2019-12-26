import 'package:flutter/widgets.dart';

abstract class VisibilityStack {
  VisibilityStack({
    @required this.delay,
    @required this.showItemInterval,
  });

  Duration delay, showItemInterval;
  AnimationDirection direction = AnimationDirection.toEnd;
  bool _isAnimated = false, _firstAnimation = true;

  final List<Function> _stack = [];

  void add(VoidCallback callback) {
    _stack.add(callback);
    animate();
  }

  @protected
  void show() {
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

  @protected
  void animate() {
    if (_isAnimated) {
      return;
    }
    _isAnimated = true;

    Duration delay =
        this.delay < showItemInterval ? showItemInterval : this.delay;
    delay = _firstAnimation ? delay : showItemInterval;

    Future.delayed(delay, () {
      if (_stack.isNotEmpty) {
        if (_firstAnimation) {
          _firstAnimation = false;
        }
        show();
        _isAnimated = false;
        animate();
      } else {
        _isAnimated = false;
      }
    });
  }

  void dispose() {}

  @override
  bool operator ==(Object o) =>
      o is VisibilityStack && showItemInterval == o.showItemInterval;

  @override
  int get hashCode => showItemInterval.hashCode;
}

enum AnimationDirection {
  toStart,
  toEnd,
}

class AnimateOnVisibilityStack extends VisibilityStack {
  AnimateOnVisibilityStack({
    @required Duration delay,
    @required Duration showItemInterval,
  }) : super(
          delay: delay,
          showItemInterval: showItemInterval,
        );

  @override
  void show() {
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
}

class ListStack extends VisibilityStack {
  ListStack({
    @required Duration delay,
    @required Duration showItemInterval,
  }) : super(
          delay: delay,
          showItemInterval: showItemInterval,
        );

  @override
  void show() {
    _stack
      ..first.call()
      ..removeAt(0);
  }
}
