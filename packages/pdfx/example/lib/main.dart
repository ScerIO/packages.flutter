import 'package:flutter/material.dart';
import 'package:pdfx_example/pinch.dart';
import 'package:pdfx_example/simple.dart';
import 'package:universal_platform/universal_platform.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(primaryColor: Colors.white),
        darkTheme: ThemeData.dark(),
        home: UniversalPlatform.isWindows
            ? const SimplePage()
            : const PinchPage(),
      );
}
