# Auto animated

Auto animated widgets for flutter 
Already added:
- `AutoAnimatedList`
- `AutoAnimatedSliverList`
- `AutoAnimatedGrid`
- `AutoAnimatedSliverGrid`
- `AutoAnimatedIconButton`

## Screenshots
<p float="left">
    <img src='https://github.com/rbcprolabs/packages.flutter/raw/master/packages/auto_animated/example/media/horizontal.gif' width="20%" hspace="1%">
    <img src='https://github.com/rbcprolabs/packages.flutter/raw/master/packages/auto_animated/example/media/vertical.gif' width="20%" hspace="1%">
    <img src='https://github.com/rbcprolabs/packages.flutter/raw/master/packages/auto_animated/example/media/combined.gif' width="20%" hspace="1%">
    <img src='https://github.com/rbcprolabs/packages.flutter/raw/master/packages/auto_animated/example/media/icon_button.gif' width="20%" hspace="1%">
</p>

## Getting Started
In your flutter project add the dependency:

[![pub package](https://img.shields.io/pub/v/auto_animated.svg)](https://pub.dartlang.org/packages/auto_animated)

```dart
dependencies:
  ...
  auto_animated: any
```
For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## `AutoAnimatedList` usage example
### Make an automatically animated list in 2 minutes? Easily!

```dart
AutoAnimatedList(
    // Start animation after (default zero)
    delay: Duration(seconds: 1),
    // Show each item through
    showItemInterval: Duration(milliseconds: 500),
    // Animation duration
    showItemDuration: Duration(seconds: 1),
    // Other properties correspond to the `ListView` widget
    scrollDirection: Axis.horizontal,
    itemsCount: 10,
    itemBuilder: _buildAnimatedItem,
)

// Build item
Widget _buildAnimatedItem(
    BuildContext context,
    int index,
    Animation<double> animation,
) =>
    // Wrap with fade transition
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
    )
```

## `AutoAnimatedIconButton` usage example
### Basic
```dart
AutoAnimatedIconButton(
    icon: AnimatedIcons.arrow_menu,
    onPressed: () {},
)
```
### With separate toolips
```dart
AutoAnimatedIconButton(
    icon: AnimatedIcons.arrow_menu,
    firstToolip: 'Event',
    secondToolip: 'Add',
)
```
