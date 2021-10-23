import 'package:auto_animated/auto_animated.dart';
import 'package:auto_animated_example/utils.dart';
import 'package:flutter/material.dart';

class LiveGridExample extends StatefulWidget {
  @override
  _LiveGridExampleState createState() => _LiveGridExampleState();
}

class _LiveGridExampleState extends State<LiveGridExample> {
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
          child: LiveGrid(
            padding: EdgeInsets.all(16),
            showItemInterval: Duration(milliseconds: 50),
            showItemDuration: Duration(milliseconds: 150),
            visibleFraction: 0.001,
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
