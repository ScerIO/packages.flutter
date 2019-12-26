import 'package:flutter/material.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:auto_animated_example/utils.dart';

class AutoAnimatedGridExample extends StatefulWidget {
  @override
  _AutoAnimatedGridExampleState createState() =>
      _AutoAnimatedGridExampleState();
}

class _AutoAnimatedGridExampleState extends State<AutoAnimatedGridExample> {
  int itemsCount = 20;
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500) * 5, () {
      if (!mounted) {
        return;
      }
      setState(() {
        itemsCount += 10;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: AutoAnimatedGrid(
            padding: EdgeInsets.all(16),
            showItemInterval: Duration(milliseconds: 150),
            showItemDuration: Duration(milliseconds: 300),
            itemCount: itemsCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: animationItemBuilder(
                (index) => HorizontalItem(title: index.toString())),
          ),
        ),
      );
}
