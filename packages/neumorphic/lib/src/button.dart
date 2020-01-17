import 'package:flutter/widgets.dart';
import 'package:neumorphic/src/neumorphic.dart';

class NeumorphicButton extends StatefulWidget {
  const NeumorphicButton({
    @required this.onPressed,
    this.child,
    this.padding = const EdgeInsets.all(24.0),
    Key key,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;

  @override
  _NeumorphicButtonState createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  void _tapDown() {
    if (!_isPressed) {
      setState(() {
        _isPressed = true;
      });
    }
  }

  void _tapUp() {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => _tapDown(),
        onTapUp: (_) => _tapUp(),
        onTapCancel: _tapUp,
        onTap: widget.onPressed,
        child: Neumorphic(
          neumorphicShape:
              _isPressed ? NeumorphicShape.concave : NeumorphicShape.convex,
          padding: widget.padding,
          child: widget.child,
        ),
      );
}
