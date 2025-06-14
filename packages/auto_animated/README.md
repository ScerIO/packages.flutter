# Auto animated
### Make an animated on scroll widgets in 2 minutes? Easily!
## Showcase

| ListView                                                                                                                       | GridView                                                                                                                       | Sliver                                                                                                                           |
|--------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| ![](https://raw.githubusercontent.com/ScerIO/packages.flutter/main/packages/auto_animated/example/media/2.0/list.gif?raw=true) | ![](https://raw.githubusercontent.com/ScerIO/packages.flutter/main/packages/auto_animated/example/media/2.0/grid.gif?raw=true) | ![](https://raw.githubusercontent.com/ScerIO/packages.flutter/main/packages/auto_animated/example/media/2.0/sliver.gif?raw=true) |

## Getting Started

In your flutter project add the dependency:

[![pub package](https://img.shields.io/pub/v/auto_animated.svg)](https://pub.dartlang.org/packages/auto_animated)

```yaml
dependencies:
  auto_animated: any
```

## Api overview

List
- `LiveList`
- `LiveSliverList`

Grid
- `LiveGrid`
- `LiveSliverGrid`

All (Animate on scroll for all widgets in all scroll view)
- `AnimateIfVisibleWrapper`
- `AnimateIfVisible`

Another animated widgets
- `LiveIconButton`


## Options for all examples
__declared `options` variable for all next examples__
```dart
final options = LiveOptions(
  // Start animation after (default zero)
  delay: Duration(seconds: 1),

  // Show each item through (default 250)
  showItemInterval: Duration(milliseconds: 500),

  // Animation duration (default 250)
  showItemDuration: Duration(seconds: 1),

  // Animations starts at 0.05 visible
  // item fraction in sight (default 0.025)
  visibleFraction: 0.05,

  // Repeat the animation of the appearance 
  // when scrolling in the opposite direction (default false)
  // To get the effect as in a showcase for ListView, set true
  reAnimateOnVisibility: false,
);
```

__declared `buildAnimatedItem` function for all next examples__

We use standard Flutter animations. This will allow you to customize your animations as much as possible.

```dart
// Build animated item (helper for all examples)
Widget buildAnimatedItem(
  BuildContext context,
  int index,
  Animation<double> animation,
) =>
  // For example wrap with fade transition
  FadeTransition(
    opacity: Tween<double>(
      begin: 0,
      end: 1,
    ).animate(animation),
    // And slide transition
    child: SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, -0.1),
        end: Offset.zero,
      ).animate(animation),
      // Paste you Widget
      child: YouWidgetHere(),
    ),
  );
```

### List usage example
```dart
// With predefined options
LiveList.options(
  options: options,

  // Like ListView.builder, but also includes animation property
  itemBuilder: buildAnimatedItem,

  // Other properties correspond to the 
  // `ListView.builder` / `ListView.separated` widget
  scrollDirection: Axis.horizontal,
  itemCount: 10,
);

// Or raw
LiveList(
  delay: /*...*/,
  showItemInterval: /*...*/,
  // ... and all other arguments from `LiveOptions` (see above)
);
```

### Grid usage example
```dart
// With predefined options
LiveGrid.options(
  options: options,

  // Like GridView.builder, but also includes animation property
  itemBuilder: buildAnimatedItem,

  // Other properties correspond to the `ListView.builder` / `ListView.separated` widget
  itemCount: itemsCount,
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
);

// Or raw
LiveGrid(
  delay: /*...*/,
  showItemInterval: /*...*/,
  // ... and all other arguments from `LiveOptions` (see above)
);
```

### Slivers usage example
`LiveSliverList` & `LiveSliverGrid` also supports `.options` constructor like `LiveList.options()` & `LiveGrid.options()` but in this example we omit them

```dart
final scrollController = ScrollController()
final int listItemCount = 4;
final Delay listShowItemDuration = Duration(milliseconds: 250);

CustomScrollView(
  // Must add scrollController to sliver root
  controller: scrollController,

  slivers: <Widget>[
    LiveSliverList(
      // And attach root sliver scrollController to widgets
      controller: scrollController,

      showItemDuration: listShowItemDuration,
      itemCount: listItemCount,
      itemBuilder: buildAnimatedItem,
    ),
    LiveSliverGrid(
      // And attach root sliver scrollController to widgets
      controller: scrollController,

      // If list and grid simultaneously in sight
      // sync with LiveSliverList (see up)
      delay: listShowItemDuration * (listItemCount + 1),

      itemCount: 12,
      itemBuilder: buildAnimatedItem,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
    ),
  ],
);
```

### Animate all widgets on scroll
You can use different animations and different appearance times for different elements.

```dart
// Wrap scrollView with [AnimateIfVisibleWrapper]
// for synchronized (consistent) child showing
AnimateIfVisibleWrapper(
  // Show each item through (default 250)
  showItemInterval: Duration(milliseconds: 150),

  child: SingleChildScrollView(
    child: Column(
      children: <Widget>[
        // First item with `FadeTransition` and show duration 500
        AnimateIfVisible(
          key: Key('item.1'),
          duration: Duration(milliseconds: 500),
          builder: (
            BuildContext context,
            int index,
            Animation<double> animation,
          ) =>
            FadeTransition(
              opacity: Tween<double>(
                begin: 0,
                end: 1,
              ).animate(animation),
              child: YouFirstWidget(),
            ),
        ),

        // Second item with `SlideTransition` and show duration 350
        AnimateIfVisible(
          key: Key('item.2'),
          duration: Duration(milliseconds: 350),
          builder: (
            BuildContext context,
            int index,
            Animation<double> animation,
          ) =>
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, -0.1),
                end: Offset.zero,
              ).animate(animation),
              child: YouSecondWidget(),
            ),
        ),
      ],
    ),
  ),
);
```

## `LiveIconButton` usage example
```dart
// Simple
LiveIconButton(
  icon: AnimatedIcons.arrow_menu,
  onPressed: () {},
);

// With separate tooltips
LiveIconButton(
  icon: AnimatedIcons.arrow_menu,
  firstTooltip: 'Event',
  secondTooltip: 'Add',
  onPressed: () {},
);
```
