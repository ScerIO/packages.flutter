import 'package:flutter/painting.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('hex color', () {
    test('Normal color', () {
      expect(HexColor('#FFFFFF').value, equals(const Color(0xFFFFFFFF).value));
      expect(HexColor('FFFFFF').value, equals(const Color(0xFFFFFFFF).value));
    });
    test('Color with transparent', () {
      expect(
          HexColor('#B1FFFFFF').value, equals(const Color(0xB1FFFFFF).value));
      expect(
          HexColor('#00FFFFFF').value, equals(const Color(0x00FFFFFF).value));
      expect(HexColor('00FFFFFF').value, equals(const Color(0x00FFFFFF).value));
    });
  });

  group('Helpers', () {
    test('conversation', () {
      expect(const Color.fromRGBO(255, 255, 255, 1).asHexString, '#FFFFFFFF');
    });

    test('lighter', () {
      expect(const Color(0xFF000000).lighter(100), const Color(0xFFFFFFFF));
      expect(
        const Color.fromARGB(255, 64, 64, 64).lighter(50),
        const Color.fromARGB(255, 192, 192, 192),
      );
    });

    test('darker', () {
      expect(const Color(0xFFFFFFFF).darker(100), const Color(0xFF000000));
      expect(
        const Color.fromARGB(255, 192, 192, 192).darker(25),
        const Color.fromARGB(255, 128, 128, 128),
      );
    });

    test('mix', () {
      expect(const Color(0xFFFFFFFF).mix(const Color(0xFF000000), 1),
          const Color(0xFF000000));
      expect(const Color(0xFFFFFFFF).mix(const Color(0xFF000000), .5),
          const Color(0xFF7F7F7F));
      expect(const Color(0xFFB5A642).mix(const Color(0xFF6C541E), .37),
          const Color(0xFF998734));
      expect(const Color(0xFFFF0000).mix(const Color(0xFF00FF00), .25),
          const Color(0xFFBF3F00));
    });
  });
}
