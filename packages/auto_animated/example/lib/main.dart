import 'package:auto_animated_example/screens/animate_on_visibility.dart';
import 'package:auto_animated_example/screens/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_animated_example/screens/icon_button.dart';
import 'package:auto_animated_example/screens/list.dart';
import 'package:auto_animated_example/screens/sliver.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final List<Widget> _children = [
    AutoAnimatedListExample(),
    AutoAnimatedGridExample(),
    SliverExample(),
    AnimateOnVisibilityExample(),
    AutoAnimatedIconButtonExample(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          backgroundColor: Colors.grey[100],
          scaffoldBackgroundColor: Colors.grey[200],
        ),
        home: Scaffold(
          body: _children[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                title: Text('List'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_on),
                title: Text('Grid'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.view_day),
                title: Text('Sliver'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.remove_red_eye),
                title: Text('On visibility'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle),
                title: Text('IconButton'),
              ),
            ],
            currentIndex: _selectedIndex,
            // selectedItemColor: Colors.amber[800],
            onTap: _onItemTapped,
          ),
        ),
      );
}
