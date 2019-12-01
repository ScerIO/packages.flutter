import 'package:flutter/material.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:auto_animated_example/utils.dart';

class AutoAnimatedListExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.title.copyWith(color: Colors.black);

    return Scaffold(
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
              width: double.infinity,
              child: HorizontalExample(),
            ),
            Text('Vertical AutoAnimatedList', style: textStyle),
            Expanded(
              child: VerticalExample(),
            ),
          ],
        ),
      ),
    );
  }
}

class HorizontalExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AutoAnimatedList(
        showItemInterval: Duration(milliseconds: 500),
        showItemDuration: Duration(seconds: 1),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: _buildAnimatedItem,
      );

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
          child: Padding(
            padding: EdgeInsets.only(right: 32),
            child: HorizontalItem(title: index.toString()),
          ),
        ),
      );
}

class VerticalExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AutoAnimatedList(
        delay: Duration(seconds: 2),
        showItemInterval: Duration(milliseconds: 500),
        showItemDuration: Duration(seconds: 1),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        scrollDirection: Axis.vertical,
        itemCount: 10,
        itemBuilder: _buildAnimatedItem,
      );

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
}
