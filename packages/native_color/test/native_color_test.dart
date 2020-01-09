import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:native_color/native_color.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('hex color', () {
    test('Normal color', () {
      expect(HexColor('#FFFFFF').value, equals(Color(0xFFFFFFFF).value));
      expect(HexColor('FFFFFF').value, equals(Color(0xFFFFFFFF).value));
    });
    test('Color with transparent', () {
      expect(HexColor('#B1FFFFFF').value, equals(Color(0xB1FFFFFF).value));
      expect(HexColor('#00FFFFFF').value, equals(Color(0x00FFFFFF).value));
      expect(HexColor('00FFFFFF').value, equals(Color(0x00FFFFFF).value));
    });
  });
}
