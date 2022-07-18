import 'package:flutter/widgets.dart' hide Stack;

class Animatable {
  Animatable(this.key, this.callback);

  final Key? key;
  final VoidCallback callback;
}

class DirectionStack {
  DirectionStack(this.items, this.direction);

  final List<Animatable> items;
  final AnimationDirection direction;
}

class VisibilityStack {
  VisibilityStack({
    required this.delay,
    required this.showItemInterval,
  });

  Duration delay, showItemInterval;
  bool _firstAnimation = true;
  final Map<AnimationDirection, bool> _isAnimatedTo = {
    AnimationDirection.toEnd: false,
    AnimationDirection.toStart: false,
  };

  DirectionStack _stack = DirectionStack([], AnimationDirection.toEnd);
  final Map<Key?, bool> _alreadyAnimated = {};

  AnimationDirection _direction = AnimationDirection.toEnd;
  AnimationDirection get direction => _direction;
  set direction(AnimationDirection direction) {
    if (_direction == direction) {
      return;
    }
    animate(
      DirectionStack(List.from(_stack.items), _stack.direction),
      showItemInterval ~/ 10,
    );
    _stack = DirectionStack([], direction);
    _direction = direction;
  }

  void add(Key? key, VoidCallback callback) {
    _stack.items.add(Animatable(key, callback));

    _alreadyAnimated[key] = false;

    animate(_stack, showItemInterval);
    if (_firstAnimation) {
      _firstAnimation = false;
    }
  }

  void show(DirectionStack stack) {
    Animatable animatable;
    if (stack.direction == AnimationDirection.toEnd) {
      animatable = stack.items.first;
      stack.items.removeAt(0);
    } else {
      animatable = stack.items.last;
      stack.items.removeLast();
    }
    animatable.callback();
    _alreadyAnimated[animatable.key] = true;
  }

  bool isAlreadyAnimated(Key? key) => _alreadyAnimated[key] ?? false;

  void animate(DirectionStack stack, Duration showItemInterval) {
    if (_isAnimatedTo[stack.direction]!) {
      return;
    }
    _isAnimatedTo[stack.direction] = true;

    final showDelay = _firstAnimation ? delay : showItemInterval;

    Future.delayed(showDelay, () {
      if (stack.items.isNotEmpty) {
        show(stack);
        _isAnimatedTo[stack.direction] = false;
        animate(stack, showItemInterval);
      } else {
        _isAnimatedTo[stack.direction] = false;
      }
    });
  }

  void dispose() {
    _stack.items.clear();
    _alreadyAnimated.clear();
  }

  @override
  bool operator ==(Object other) =>
      other is VisibilityStack && showItemInterval == other.showItemInterval;

  @override
  int get hashCode => showItemInterval.hashCode;
}

enum AnimationDirection {
  toStart,
  toEnd,
}
