import 'package:flutter/widgets.dart';
import 'package:neumorphic/src/neumorphic.dart';

class NeumorphicButton extends StatefulWidget {
  const NeumorphicButton({
    @required this.onPressed,
    this.child,
    this.padding = const EdgeInsets.all(12.0),
    this.shape = BoxShape.rectangle,
    Key key,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final BoxShape shape;

  @override
  _NeumorphicButtonState createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  void _toggle(bool value) {
    if (_isPressed != value) {
      setState(() {
        _isPressed = value;
      });
    }
  }

  void _tapDown() => _toggle(true);

  void _tapUp() => _toggle(false);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => _tapDown(),
        onTapUp: (_) => _tapUp(),
        onTapCancel: _tapUp,
        onTap: widget.onPressed,
        child: Neumorphic(
          status:
              _isPressed ? NeumorphicStatus.concave : NeumorphicStatus.convex,
          padding: widget.padding,
          child: widget.child,
          decoration: NeumorphicDecoration(
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : BorderRadius.circular(16),
            shape: widget.shape,
          ),
        ),
      );
}
