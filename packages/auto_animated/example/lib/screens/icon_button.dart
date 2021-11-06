import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';

class LiveIconButtonExample extends StatefulWidget {
  @override
  _LiveIconButtonExampleState createState() => _LiveIconButtonExampleState();
}

class _LiveIconButtonExampleState extends State<LiveIconButtonExample> {
  bool _externalState = false;

  @override
  Widget build(BuildContext context) => Scaffold(
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
                  leading: LiveIconButton(
                    icon: AnimatedIcons.menu_close,
                    firstTooltip: 'Menu',
                    secondTooltip: 'Close',
                    onPressed: () {},
                  ),
                ),
              ),
              LiveIconButton.externalState(
                icon: AnimatedIcons.arrow_menu,
                onPressed: () {
                  setState(() {
                    _externalState = !_externalState;
                  });
                },
                iconState: !_externalState ? IconState.first : IconState.second,
              ),
              LiveIconButton(
                icon: AnimatedIcons.play_pause,
                onPressed: () {},
              ),
              LiveIconButton(
                icon: AnimatedIcons.search_ellipsis,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
}
