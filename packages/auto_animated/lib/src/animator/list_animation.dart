import 'package:auto_animated/src/helpers/callbacks.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

// The default insert/remove animation duration.
const Duration _kDuration = Duration(milliseconds: 300);

// Incoming and outgoing LiveList items.
class ActiveItem implements Comparable<ActiveItem> {
  ActiveItem.incoming(this.controller, this.itemIndex)
      : removedItemBuilder = null;
  ActiveItem.outgoing(this.controller, this.itemIndex, this.removedItemBuilder);
  ActiveItem.index(this.itemIndex)
      : controller = null,
        removedItemBuilder = null;

  final AnimationController? controller;
  final LiveListRemovedItemBuilder? removedItemBuilder;
  int itemIndex;

  @override
  int compareTo(ActiveItem other) => itemIndex - other.itemIndex;
}

mixin ListAnimation<T extends StatefulWidget> on State<T> {
  @protected
  final List<ActiveItem> incomingItems = <ActiveItem>[];
  @protected
  final List<ActiveItem> outgoingItems = <ActiveItem>[];
  @protected
  int itemsCount = 0;

  @protected
  TickerProvider get vsync;

  @protected
  ActiveItem? removeActiveItemAt(List<ActiveItem> items, int itemIndex) {
    final int i = binarySearch(items, ActiveItem.index(itemIndex));
    return i == -1 ? null : items.removeAt(i);
  }

  @protected
  ActiveItem? activeItemAt(List<ActiveItem> items, int itemIndex) {
    final int i = binarySearch(items, ActiveItem.index(itemIndex));
    return i == -1 ? null : items[i];
  }

  // The insertItem() and removeItem() index parameters are defined as if the
  // removeItem() operation removed the corresponding list entry immediately.
  // The entry is only actually removed
  // from the ListView when the remove animation
  // finishes. The entry is added to outgoingItems when removeItem is called
  // and removed from outgoingItems when the remove animation finishes.
  @protected
  int indexToItemIndex(int index) {
    int itemIndex = index;
    for (ActiveItem item in outgoingItems) {
      if (item.itemIndex <= itemIndex) {
        itemIndex += 1;
      } else {
        break;
      }
    }
    return itemIndex;
  }

  /// Insert an item at [index] and start an animation that will be passed
  /// to itemBuilder when the item is visible.
  ///
  /// This method's semantics are the same as Dart's [List.insert] method:
  /// it increases the length of the list by one and shifts all items at or
  /// after [index] towards the end of the list.
  void insertItem(int index, {Duration duration = _kDuration}) {
    assert(index >= 0);

    final int itemIndex = indexToItemIndex(index);
    assert(itemIndex >= 0 && itemIndex <= itemsCount);

    // Increment the incoming and outgoing item indices to account
    // for the insertion.
    for (ActiveItem item in incomingItems) {
      if (item.itemIndex >= itemIndex) {
        item.itemIndex += 1;
      }
    }
    for (ActiveItem item in outgoingItems) {
      if (item.itemIndex >= itemIndex) {
        item.itemIndex += 1;
      }
    }

    final AnimationController controller =
        AnimationController(duration: duration, vsync: vsync);
    final ActiveItem incomingItem = ActiveItem.incoming(controller, itemIndex);
    setState(() {
      incomingItems
        ..add(incomingItem)
        ..sort();
      itemsCount += 1;
    });

    controller.forward().then<void>((_) {
      removeActiveItemAt(incomingItems, incomingItem.itemIndex)!
          .controller!
          .dispose();
    });
  }

  /// Remove the item at [index] and start an animation that will be passed
  /// to [builder] when the item is visible.
  ///
  /// Items are removed immediately. After an item has been removed, its index
  /// will no longer be passed to the itemBuilder.
  /// However the
  /// item will still appear in the list for [duration] and during that time
  /// [builder] must construct its widget as needed.
  ///
  /// This method's semantics are the same as Dart's [List.remove] method:
  /// it decreases the length of the list by one and shifts all items at or
  /// before [index] towards the beginning of the list.
  void removeItem(
    int index,
    LiveListRemovedItemBuilder builder, {
    Duration duration = _kDuration,
  }) {
    assert(index >= 0);

    final int itemIndex = indexToItemIndex(index);
    assert(itemIndex >= 0 && itemIndex < itemsCount);
    assert(activeItemAt(outgoingItems, itemIndex) == null);

    final ActiveItem? incomingItem =
        removeActiveItemAt(incomingItems, itemIndex);
    final AnimationController controller = incomingItem?.controller ??
        AnimationController(duration: duration, value: 1.0, vsync: vsync);
    final ActiveItem outgoingItem =
        ActiveItem.outgoing(controller, itemIndex, builder);
    setState(() {
      outgoingItems
        ..add(outgoingItem)
        ..sort();
    });

    controller.reverse().then<void>((void value) {
      removeActiveItemAt(outgoingItems, outgoingItem.itemIndex)!
          .controller!
          .dispose();

      // Decrement the incoming and outgoing item indices to account
      // for the removal.
      for (ActiveItem item in incomingItems) {
        if (item.itemIndex > outgoingItem.itemIndex) {
          item.itemIndex -= 1;
        }
      }
      for (ActiveItem item in outgoingItems) {
        if (item.itemIndex > outgoingItem.itemIndex) {
          item.itemIndex -= 1;
        }
      }

      setState(() {
        itemsCount -= 1;
      });
    });
  }
}
