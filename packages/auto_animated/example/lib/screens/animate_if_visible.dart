import 'package:flutter/material.dart';
import 'package:auto_animated_example/utils.dart';
import 'package:auto_animated/auto_animated.dart';

class AnimateIfVisibleExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          // Wrapper before Scroll view!
          child: AnimateIfVisibleWrapper(
            showItemInterval: Duration(milliseconds: 150),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < 20; i++)
                    AnimateIfVisible(
                      key: Key('$i'),
                      builder: animationBuilder(
                        SizedBox(
                          width: double.infinity,
                          height: 128,
                          child: HorizontalItem(
                            title: '$i',
                          ),
                        ),
                        xOffset: i.isEven ? 0.15 : -0.15,
                        padding: EdgeInsets.all(16),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}
