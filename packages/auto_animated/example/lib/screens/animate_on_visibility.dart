import 'package:auto_animated_example/utils.dart';
import 'package:flutter/material.dart';
import 'package:auto_animated/auto_animated.dart';

class AnimateOnVisibilityExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.title.copyWith(color: Colors.black);

    return Scaffold(
      body: SafeArea(
        // Wrapper before Scroll view!
        child: AnimateOnVisibilityWrapper(
          showItemInterval: Duration(milliseconds: 150),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 16),
                Text('Animate elements on visibility', style: textStyle),
                for (int i = 0; i < 20; i++)
                  AnimateOnVisibilityChange(
                    key: Key('$i'),
                    builder: animationBuilder(
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: HorizontalItem(
                          title: '$i',
                        ),
                      ),
                      xOffset: i.isEven ? 0.15 : -0.15,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
