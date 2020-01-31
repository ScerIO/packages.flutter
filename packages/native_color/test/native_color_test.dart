// import 'dart:ui' show Color;

import 'package:flutter/painting.dart';
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

  group('Helpers', () {
    test('lighter', () {
      expect(Color(0xFF000000).lighter(100), Color(0xFFFFFFFF));
      expect(
        Color.fromARGB(255, 64, 64, 64).lighter(50),
        Color.fromARGB(255, 192, 192, 192),
      );
    });

    test('darker', () {
      expect(Color(0xFFFFFFFF).darker(100), Color(0xFF000000));
      expect(
        Color.fromARGB(255, 192, 192, 192).darker(25),
        Color.fromARGB(255, 128, 128, 128),
      );
    });
  });
}
