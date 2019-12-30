import 'dart:async';

import 'package:flutter/widgets.dart' hide Stack;

class _Animatable {
  _Animatable(this.key, this.callback);

  final Key key;
  final VoidCallback callback;
}

class VisibilityStack {
  VisibilityStack({
    @required this.delay,
    @required this.showItemInterval,
  }) {
    // _stream = Stream.periodic(showItemInterval);
    // Future.delayed(delay, () {
    //   _listener = _stream.timeout(showItemInterval).listen((data) {
    //     show();
    //   });
    // });
  }

  Duration delay, showItemInterval;
  AnimationDirection direction = AnimationDirection.toEnd;
  bool _isAnimated = false, _firstAnimation = true;

  // Stream<Key Function()> _stream;
  // StreamSubscription _listener;

  final List<_Animatable> _stack = [];
  final Map<Key, bool> _alreadyAnimated = {};

  void add(Key key, VoidCallback callback) {
    _stack.add(_Animatable(key, callback));
    _alreadyAnimated[key] = false;

    animate();
  }

  void show() {
    _Animatable animatable;
    if (direction == AnimationDirection.toEnd) {
      animatable = _stack.first;
      _stack.removeAt(0);
    } else {
      animatable = _stack.last;
      _stack.removeLast();
    }
    animatable.callback();
    _alreadyAnimated[animatable.key] = true;
  }

  bool isAlreadyAnimated(Key key) => _alreadyAnimated[key] ?? false;

  void animate() {
    if (_isAnimated) {
      return;
    }
    _isAnimated = true;

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

  void dispose() {
    // _listener.cancel();
    _stack.clear();
    _alreadyAnimated.clear();
  }

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
