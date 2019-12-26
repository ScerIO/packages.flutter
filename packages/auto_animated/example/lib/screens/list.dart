import 'package:flutter/material.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:auto_animated_example/utils.dart';

class AutoAnimatedListExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: VerticalExample(),
              ),
            ],
          ),
        ),
      );
}

class VerticalExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AutoAnimatedList(
        showItemInterval: Duration(milliseconds: 150),
        showItemDuration: Duration(milliseconds: 500),
        padding: EdgeInsets.all(16),
        scrollDirection: Axis.vertical,
        itemCount: 10,
        itemBuilder: animationItemBuilder(
          (index) => VerticalItem(title: index.toString()),
          padding: EdgeInsets.symmetric(vertical: 8),
        ),
      );
}
