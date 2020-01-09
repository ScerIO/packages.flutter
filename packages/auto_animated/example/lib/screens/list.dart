import 'package:flutter/material.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:auto_animated_example/utils.dart';

class LiveListExample extends StatelessWidget {
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
  Widget build(BuildContext context) => LiveList(
        showItemInterval: Duration(milliseconds: 150),
        showItemDuration: Duration(milliseconds: 350),
        padding: EdgeInsets.all(16),
        reAnimateOnVisibility: true,
        scrollDirection: Axis.vertical,
        itemCount: 20,
        itemBuilder: animationItemBuilder(
          (index) => VerticalItem(title: index.toString()),
          padding: EdgeInsets.symmetric(vertical: 8),
        ),
      );
}
