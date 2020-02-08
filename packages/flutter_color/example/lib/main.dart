import 'package:flutter/material.dart';

import 'package:flutter_color/flutter_color.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(64),
              child: Column(
                children: <Widget>[
                  Text(
                    'hex',
                    style: TextStyle(color: HexColor('#ff0000')),
                  ),
                  Text(
                    'hsl',
                    style: TextStyle(color: HslColor(120, 100, 50)),
                  ),
                  Text(
                    'xyz',
                    style: TextStyle(color: XyzColor(14.31, 6.06, 71.42)),
                  ),
                  Text(
                    'cielab',
                    style: TextStyle(color: CielabColor(36.80, 55.20, -95.61)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
