import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:auto_animated_example/utils.dart';

class SliverExample extends StatelessWidget {
  /// Wrap Ui item with animation & padding
  Widget _buildAnimatedItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) =>
      FadeTransition(
        opacity: Tween<double>(
          begin: 0,
          end: 1,
        ).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, -0.1),
            end: Offset.zero,
          ).animate(animation),
          child: VerticalItem(title: index.toString()),
        ),
      );

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
                  itemBuilder: _buildAnimatedItem,
                ),
              ),
            ],
          ),
        ),
      );
}
