import 'package:flutter/widgets.dart';

class FixedSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  const FixedSliverPersistentHeaderDelegate({
    required this.child,
    this.minHeight = 52.0,
    this.maxHeight = 52.0,
  });

  const FixedSliverPersistentHeaderDelegate.empty()
      : child = null,
        minHeight = 0,
        maxHeight = 0;

  final Widget? child;
  final double minHeight, maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      child!;

  @override
  bool shouldRebuild(FixedSliverPersistentHeaderDelegate oldDelegate) => true;
}
