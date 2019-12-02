import 'package:flutter/material.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:auto_animated_example/utils.dart';

class AutoAnimatedGridExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AutoAnimatedGrid(
          showItemInterval: Duration(milliseconds: 500),
          showItemDuration: Duration(seconds: 1),
          itemCount: 10,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: animationItemBuilder(
              (index) => HorizontalItem(title: index.toString())),
        ),
      ),
    );
  }
}
