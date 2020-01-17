# neumorphic

Neumorphic Ui for flutter

![NeumorphicStatus](https://miro.medium.com/max/1024/1*EET5FBkpc738Xi75pgrH1w.png)

Includes two states:
`NeumorphicStatus.convex` (first) & 
`NeumorphicStatus.concave` (second)

## Api
Now implemented some widgets:

 - Neumorphic
 - NeumorphicButton

### Neumorphic
It is container like a `Material` merged with `Container`, but implement Neumorphism

```dart
Neumorphic(
  // State of Neumorphic (may be concave & convex)
  status: NeumorphicStatus.concave,

  // Elevation relative to parent. Main constituent of Neumorphism
  bevel: 10,

  // Specified decorations, like `BoxDecoration` but only limited
  decoration: NeumorphicDecoration(
    borderRadius: BorderRadius.circular(8)
  ),

  // Other arguments such as margin, padding etc. (Like `Container`)
  child: Text('Container')
)
```

## NeumorphicButton
Button automatically when pressed toggle the status of NeumorphicStatus from `concave` to `convex` and back
```dart
NeumorphicButton(
  onPressed: () {
    print('Pressed !');
  },
  child: Text('Button'),
);
```

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## Inspired by

[Alexander Plyuto (figma)](https://www.figma.com/file/J1uPSOY5k577mDpSfGFven/Skeuomorph-Small-Style-Guide)
[Ivan Cherepanov (medium)](https://medium.com/flutter-community/neumorphic-designs-in-flutter-eab9a4de2059)
