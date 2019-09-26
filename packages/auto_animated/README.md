# Auto animated

Auto animated list

## Screenshots
<p float="left">
    <img src='https://github.com/rbcprolabs/flutter_plugins/raw/master/packages/auto_animated/example/media/horizontal.gif' width="30%">
    <img src='https://github.com/rbcprolabs/flutter_plugins/raw/master/packages/auto_animated/example/media/vertical.gif' width="30%" hspace="4%">
    <img src='https://github.com/rbcprolabs/flutter_plugins/raw/master/packages/auto_animated/example/media/combined.gif' width="30%">
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

## Usage example
### **It very simple!**

```dart
AutoAnimatedList(
    // Start animation after (default zero)
    delay: Duration(seconds: 1),
    // Show each item through
    showItemInterval: Duration(milliseconds: 500),
    // Animation duration
    showItemDuration: Duration(seconds: 1),
    // Other properties correspond to the `AnimatedList` widget
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