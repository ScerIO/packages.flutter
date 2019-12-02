import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:auto_animated_example/utils.dart';

class SliverExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: AutoAnimatedSliverList(
                  showItemInterval: Duration(milliseconds: 500),
                  showItemDuration: Duration(seconds: 1),
                  itemCount: 4,
                  itemBuilder: animationItemBuilder(
                      (index) => VerticalItem(title: index.toString())),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: AutoAnimatedSliverGrid(
                    delay: Duration(milliseconds: 500) * 4,
                    showItemInterval: Duration(milliseconds: 500),
                    showItemDuration: Duration(seconds: 1),
                    itemCount: 6,
                    itemBuilder: animationItemBuilder(
                        (index) => HorizontalItem(title: index.toString())),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    )),
              )
            ],
          ),
        ),
      );
}
