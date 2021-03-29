const Duration _kDuration = Duration(milliseconds: 250);

class LiveOptions {
  /// Configuration suitable for reuse in
  /// Live{List,SliverList,Grid,SliverGrid}.options constructors
  /// {@tool sample}
  ///
  /// This example
  ///
  /// ```dart
  /// LiveList.options(
  ///   option: AutoAnimatedOptions(
  ///     delay: Duration(seconds: 1),
  ///     showItemInterval: Duration(milliseconds: 500),
  ///     showItemDuration: Duration(seconds: 1),
  ///     visibleFraction: 0.025,
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  const LiveOptions({
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

  /// Creates a copy of this options but with the
  /// given fields replaced with the new values.
  LiveOptions copyWith({
    Duration? delay,
    Duration? showItemInterval,
    Duration? showItemDuration,
    double? visibleFraction,
    bool? reAnimateOnVisibility,
  }) =>
      LiveOptions(
        delay: delay ?? this.delay,
        showItemInterval: showItemInterval ?? this.showItemInterval,
        showItemDuration: showItemDuration ?? this.showItemDuration,
        visibleFraction: visibleFraction ?? this.visibleFraction,
        reAnimateOnVisibility:
            reAnimateOnVisibility ?? this.reAnimateOnVisibility,
      );
}
