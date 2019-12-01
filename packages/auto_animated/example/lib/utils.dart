import 'package:flutter/material.dart';

class VerticalItem extends StatelessWidget {
  const VerticalItem({
    @required this.title,
    Key key,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 8),
        color: Theme.of(context).colorScheme.secondary,
        child: ListTile(
          leading: FlutterLogo(
            colors: Colors.pink,
          ),
          title: Text(
            '$title a long title',
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
          ),
        ),
      );
}

class HorizontalItem extends StatelessWidget {
  const HorizontalItem({
    @required this.title,
    Key key,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) => Container(
        width: 140,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Material(
            color: Theme.of(context).colorScheme.secondary,
            child: Center(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .display1
                    .copyWith(color: Theme.of(context).colorScheme.onSecondary),
              ),
            ),
          ),
        ),
      );
}
