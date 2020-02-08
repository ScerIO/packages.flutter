import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_color/flutter_color.dart';

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
    test('conversation', () {
      expect(Color.fromRGBO(255, 255, 255, 1).asHexString, '#FFFFFFFF');
    });

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

    test('mix', () {
      expect(Color(0xFFFFFFFF).mix(Color(0xFF000000), 1), Color(0xFF000000));
      expect(Color(0xFFFFFFFF).mix(Color(0xFF000000), .5), Color(0xFF7F7F7F));
      expect(Color(0xFFB5A642).mix(Color(0xFF6C541E), .37), Color(0xFF998734));
      expect(Color(0xFFFF0000).mix(Color(0xFF00FF00), .25), Color(0xFFBF3F00));
    });
  });
}
