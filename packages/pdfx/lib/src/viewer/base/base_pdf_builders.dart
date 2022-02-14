import 'package:flutter/widgets.dart';

class DefaultBuilderOptions {
  final Duration loaderSwitchDuration;
  final AnimatedSwitcherTransitionBuilder transitionBuilder;
  const DefaultBuilderOptions({
    this.loaderSwitchDuration = const Duration(seconds: 1),
    this.transitionBuilder = DefaultBuilderOptions._transitionBuilder,
  });

  static Widget _transitionBuilder(Widget child, Animation<double> animation) =>
      FadeTransition(opacity: animation, child: child);
}
