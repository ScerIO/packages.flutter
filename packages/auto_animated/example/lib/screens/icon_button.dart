import 'package:flutter/material.dart';
import 'package:auto_animated/auto_animated.dart';

class AutoAnimatedIconButtonExample extends StatefulWidget {
  @override
  _AutoAnimatedIconButtonExampleState createState() =>
      _AutoAnimatedIconButtonExampleState();
}

class _AutoAnimatedIconButtonExampleState
    extends State<AutoAnimatedIconButtonExample> {
  bool _externalState = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: AppBar(
                primary: false,
                title: Text('Auto animated Icon'),
                // Implement animated icon
                leading: AutoAnimatedIconButton(
                  icon: AnimatedIcons.menu_close,
                  firstToolip: 'Menu',
                  secondToolip: 'Close',
                  onPressed: () {},
                ),
              ),
            ),
            AutoAnimatedIconButton.externalState(
              icon: AnimatedIcons.arrow_menu,
              onPressed: () {
                setState(() {
                  _externalState = !_externalState;
                });
              },
              iconState: !_externalState ? IconState.first : IconState.second,
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
}
