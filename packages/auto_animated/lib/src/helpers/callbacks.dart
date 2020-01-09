import 'package:flutter/widgets.dart';

/// Signature for the builder callback
typedef LiveListItemBuilder = Widget Function(
    BuildContext context, int index, Animation<double> animation);

/// Signature for the builder callback
typedef LiveListRemovedItemBuilder = Widget Function(
    BuildContext context, Animation<double> animation);
