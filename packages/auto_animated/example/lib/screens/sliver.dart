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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: AutoAnimatedSliverList(
                  showItemInterval: Duration(milliseconds: 250),
                  showItemDuration: Duration(milliseconds: 300),
                  itemCount: 4,
                  itemBuilder: animationItemBuilder(
                      (index) => VerticalItem(title: index.toString()),
                      padding: EdgeInsets.symmetric(vertical: 8)),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: AutoAnimatedSliverGrid(
                  delay: Duration(milliseconds: 250) * 5,
                  showItemInterval: Duration(milliseconds: 250),
                  showItemDuration: Duration(milliseconds: 300),
                  itemCount: 12,
                  itemBuilder: animationItemBuilder(
                    (index) => HorizontalItem(title: index.toString()),
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                ),
              )
            ],
          ),
        ),
      );
}
