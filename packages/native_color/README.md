# native_color

A new flutter plugin project.

## Examples

*HexColor*:
```dart
main() {
  assert(HexColor('000000')    == Color(0xFF000000));
  assert(HexColor('FFFFFFFF')  == Color(0xFFFFFFFF));
  assert(HexColor('#B1000000') == Color(0xB1000000));
}
```
*HslColor*:
```dart
main() {
  assert(HslColor(164, 100, 88) == Color(0xFFC2FFEF));
}
```
*HyzColor*:
```dart
main() {
  assert(XyzColor(0.1669, 0.2293, 0.0434) == Color(0xFF659027));
}
```
*CielabColor*:
```dart
main() {
  assert(CielabColor(36.80, 55.20, -95.61) == Color(0xFF4832F7));
}
```

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.io/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
