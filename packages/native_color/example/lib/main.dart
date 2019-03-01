import 'package:flutter/material.dart';

import 'package:native_color/native_color.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(64),
          child: Column(
            children: <Widget>[
              Text(
                'Color hex',
                style: TextStyle(color: HexColor('#ff0000')),
              ),
              Text(
                'Color hsl',
                style: TextStyle(color: HslColor(120, 100, 50)),
              ),
              Text(
                'Color xyz',
                style: TextStyle(color: XyzColor(14.31, 6.06, 71.42)),
              ),
              Text(
                'Color cielab',
                style: TextStyle(color: XyzColor(60.17, 93.55, -60.50)),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
