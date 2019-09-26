import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'horizontal.dart';
import 'vertical.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.grey[100],
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.title.copyWith(color: Colors.black);
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 16,
              ),
              Text('Horizontal AutoAnimatedList', style: textStyle),
              SizedBox(
                height: 200,
                child: HorizontalExample(),
              ),
              Text('Vertical AutoAnimatedList', style: textStyle),
              SizedBox(
                height: 400,
                child: VerticalExample(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
