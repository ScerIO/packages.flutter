import 'package:flutter/material.dart';

import 'package:neumorphic/neumorphic.dart';

void main() => runApp(NeumorphicApp());

class NeumorphicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Neumorphic App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          backgroundColor: Colors.blueGrey.shade200,
          scaffoldBackgroundColor: Colors.blueGrey.shade200,
          dialogBackgroundColor: Colors.blueGrey.shade200,
        ),
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: double.maxFinite),
                Neumorphic(
                  padding: EdgeInsets.all(48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Neumorphic container',
                        style: Typography.blackCupertino.display1
                            .copyWith(fontSize: 24),
                      ),
                      SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Neumorphic(
                            padding: EdgeInsets.all(12),
                            neumorphicShape: NeumorphicShape.concave,
                            child: Text(
                              'concave',
                              style: Typography.blackCupertino.display1
                                  .copyWith(fontSize: 16),
                            ),
                          ),
                          Neumorphic(
                            padding: EdgeInsets.all(12),
                            neumorphicShape: NeumorphicShape.convex,
                            child: Text(
                              'convex',
                              style: Typography.blackCupertino.display1
                                  .copyWith(fontSize: 16),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 64),
                NeumorphicButton(
                  child: Text('Button'),
                  onPressed: () {
                    print('pressed');
                  },
                ),
              ],
            ),
          ),
        ),
      );
}
