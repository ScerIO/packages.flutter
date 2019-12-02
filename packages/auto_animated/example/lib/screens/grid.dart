import 'package:flutter/material.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:auto_animated_example/utils.dart';

class AutoAnimatedGridExample extends StatefulWidget {
  @override
  _AutoAnimatedGridExampleState createState() =>
      _AutoAnimatedGridExampleState();
}

class _AutoAnimatedGridExampleState extends State<AutoAnimatedGridExample> {
  int itemsCount = 4;
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500) * 5, () {
      setState(() {
        itemsCount += 10;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AutoAnimatedGrid(
          showItemInterval: Duration(milliseconds: 500),
          showItemDuration: Duration(seconds: 1),
          itemCount: itemsCount,
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
