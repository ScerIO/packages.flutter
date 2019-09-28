import 'package:flutter/material.dart';
import 'package:auto_animated/auto_animated.dart';

class AutoAnimatedIconButtonExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Auto animated Icon'),
          // Implement animated icon
          leading: AutoAnimatedIconButton(
            icon: AnimatedIcons.menu_close,
            firstToolip: 'Menu',
            secondToolip: 'Close',
            onPressed: () {},
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AutoAnimatedIconButton(
                icon: AnimatedIcons.arrow_menu,
                onPressed: () {},
              ),
              AutoAnimatedIconButton(
                icon: AnimatedIcons.play_pause,
                onPressed: () {},
              ),
              AutoAnimatedIconButton(
                icon: AnimatedIcons.search_ellipsis,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
}
