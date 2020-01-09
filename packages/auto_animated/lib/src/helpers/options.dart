const Duration _kDuration = Duration(milliseconds: 250);

class AutoAnimatedOptions {
  const AutoAnimatedOptions({
    this.delay = Duration.zero,
    this.showItemInterval = _kDuration,
    this.showItemDuration = _kDuration,
    this.visibleFraction = 0.025,
    this.reAnimateOnVisibility = false,
  });

  /// Start animation after (default zero)
  final Duration delay;

  /// Show each item through
  final Duration showItemInterval;

  /// Animation duration
  final Duration showItemDuration;

  /// A fraction in the range \[0, 1\] that represents what proportion of the
  /// widget is visible (assuming rectangular bounding boxes).
  ///
  /// 0 means not visible; 1 means fully visible.
  final double visibleFraction;

  /// Hide the element when it approaches the
  /// frame of the screen so that in the future,
  /// when it falls into the visibility range - reproduce animation again
  final bool reAnimateOnVisibility;

  AutoAnimatedOptions copyWith({
    Duration delay,
    Duration showItemInterval,
    Duration showItemDuration,
    double visibleFraction,
    bool reAnimateOnVisibility,
  }) =>
      AutoAnimatedOptions(
        delay: delay ?? this.delay,
        showItemInterval: showItemInterval ?? this.showItemInterval,
        showItemDuration: showItemDuration ?? this.showItemDuration,
        visibleFraction: visibleFraction ?? this.visibleFraction,
        reAnimateOnVisibility:
            reAnimateOnVisibility ?? this.reAnimateOnVisibility,
      );
}
