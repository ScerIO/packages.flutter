import 'package:flutter/material.dart';

import 'package:neumorphic_example/screen.dart';

void main() => runApp(NeumorphicApp());

class NeumorphicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Neumorphic App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          backgroundColor: Color.lerp(Colors.grey[200], Colors.black, 0.005),
          scaffoldBackgroundColor: Colors.grey[200],
          dialogBackgroundColor: Colors.grey[300],
        ),
        home: Neumorphism(),
      );
}
