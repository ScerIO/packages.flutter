import 'package:flutter/widgets.dart';

/// Signature for the builder callback
typedef AutoAnimatedListItemBuilder = Widget Function(
    BuildContext context, int index, Animation<double> animation);

/// Signature for the builder callback
typedef AutoAnimatedListRemovedItemBuilder = Widget Function(
    BuildContext context, Animation<double> animation);
