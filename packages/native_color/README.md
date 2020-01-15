# native_color

Flutter package widening a Color class which can be used to create, convert, compare colors and uses in UI. And also for working with editing color

```dart
// Usage hex from string and alternative color systems

HexColor('000000')                 // -> Color(0xFF000000)
HslColor(164, 100, 88)             // -> Color(0xFFC2FFEF)
XyzColor(0.1669, 0.2293, 0.0434)   // -> Color(0xFF659027)
CielabColor(36.80, 55.20, -95.61)  // -> Color(0xFF4832F7)

// Make color darker or lighter
Color(0xFF000000).lighter(100)     // -> Color(0xFFFFFFFF)
Color(0xFF000000).darker(50)       // -> Color(0xFF808080)
```


## Getting Started

In your flutter project add the dependency:

[![pub package](https://img.shields.io/pub/v/native_color.svg)](https://pub.dartlang.org/packages/native_color)

```yaml
dependencies:
  native_color: any
```

For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## Examples

```dart
// HexColor
assert(HexColor('000000')    == Color(0xFF000000));
assert(HexColor('#000000')   == Color(0xFF000000));
assert(HexColor('FFFFFFFF')  == Color(0xFFFFFFFF));
assert(HexColor('#B1000000') == Color(0xB1000000));
assert(HexColor('#B1000000').hexColor, '#B1000000');

// HslColor
assert(HslColor(164, 100, 88) == Color(0xFFC2FFEF));

// HyzColor
assert(XyzColor(0.1669, 0.2293, 0.0434) == Color(0xFF659027));

/// CielabColor
assert(CielabColor(36.80, 55.20, -95.61) == Color(0xFF4832F7));
```

*Make color darker or lighter*
Usage dart extension methods
```dart
// [black -> white] lighter by 100 percents
assert(Color(0xFF000000).lighter(100), Color(0xFFFFFFFF));
// Another lighter example
assert(Color.fromARGB(255, 64, 64, 64).lighter(50),   Color.fromARGB(255, 192, 192, 192));

// [white -> grey] darker by 50 percents
assert(Color(0xFF000000).darker(50), Color(0xFF808080));
// Another darker example
assert(Color.fromARGB(255, 192, 192, 192).darker(25), Color.fromARGB(255, 128, 128, 128));
```
How it works? [Easy :)](https://graphicdesign.stackexchange.com/a/75419)

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.io/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## Inspired by

[Color dart package](https://pub.dev/packages/color)
